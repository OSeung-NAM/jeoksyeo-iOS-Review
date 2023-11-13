//
//  SignUpVC.swift
//  WetProject
//
//  Created by 남오승 on 2020/10/19.
//

import UIKit
import ReactorKit
import RxSwift
import RxCocoa

//회원가입 화면 UI를 컨트롤 하기위한 파일
class SignUpVC: BaseViewController,StoryboardView {
    
    @IBOutlet weak var progressImage: UIImageView!
    
    var check:Bool = true
    @IBOutlet weak var signUpCV: UICollectionView!
    
    var signUpNameCell:SignUpNameCell?
    var signUpBirthCell:SignUpBirthCell?
    var signUpGenderCell:SignUpGenderCell?
    var signUpAreaSettingCell:SignUpAreaSettingCell?
    
    var signUpArr:[String] = [String]()
    
    var userInfo:User?
    
    var hasBirth:Bool = false
    var hasGender:Bool = false
    
    let signUpRT = SignUpRT()
    
    var socialDivision:String = String()
    
    var nickName:String = String()
    var birth:String = String()
    var gender:String = String()
    var area:String = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        signUpCV.delegate = self
        signUpCV.dataSource = self
        signUpCV.backgroundColor = .white
        signUpCV.register(UINib(nibName: "SignUpNameCell", bundle: nil), forCellWithReuseIdentifier: "SignUpNameCell")
        signUpCV.register(UINib(nibName: "SignUpBirthCell", bundle: nil), forCellWithReuseIdentifier: "SignUpBirthCell")
        signUpCV.register(UINib(nibName: "SignUpGenderCell", bundle: nil), forCellWithReuseIdentifier: "SignUpGenderCell")
        signUpCV.register(UINib(nibName: "SignUpAreaSettingCell", bundle: nil), forCellWithReuseIdentifier: "SignUpAreaSettingCell")
        
        //스와이프 뒤로가기 처리
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        reactor = signUpRT
        
    }
    
    func bind(reactor:SignUpRT){
        /* State */
        
        
        
        let isIndicator = reactor.state.map{$0.isIndecator}.filter{$0 != nil}.map{$0 ?? false}
        let isSignUp = reactor.state.map{$0.isSignUp}.filter{$0 != nil}
        let isErrors = reactor.state.map{$0.isErrors}.filter{$0 != nil}.map{$0 ?? false}
        
        isIndicator.bind{[weak self] result in self?.loadingIndicator(flag: result)}.disposed(by: disposeBag)
        
        let isTimeOut = reactor.state.map{$0.isTimeOut}.filter{$0 != nil}.map{$0 ?? false}
        
        //서버 타임아웃 에러
        isTimeOut
            .bind{[weak self] result in
                if result {
                    self?.netWorkStateToast(errorIndex: 408)
                }
            }.disposed(by: disposeBag)
        
        isErrors.bind{[weak self] result in
            if result {
                self?.netWorkStateToast(errorIndex: 1)
            }
        }.disposed(by: disposeBag)
        
        isSignUp
            .bind{[weak self] result in
                self?.callback(result)
            }.disposed(by: disposeBag)
        
        /* */
    }
    override func viewDidAppear(_ animated: Bool) {
        progressUpdate(viewCnt:signUpArr.count, currentViewIndex: 1)
        tabBarController?.tabBar.isHidden = true
    }
    
    @IBAction func backBtn(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    func progressUpdate(viewCnt:Int, currentViewIndex:Int){
        progressImage.constraints.forEach { (constraint) in // ---- 3
            if constraint.firstAttribute == .height {
                constraint.constant = 16.0
            }
            
            
            if constraint.firstAttribute == .width {
                let progressWidth = (Int(UIScreen.main.bounds.width)/viewCnt)*currentViewIndex
                constraint.constant = CGFloat(progressWidth)
            }
        }
        
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
    }
    
    func nextViewMove(nextIndex:Int) {
        progressUpdate(viewCnt: signUpArr.count, currentViewIndex: nextIndex+1)
        signUpCV.scrollToItem(at: IndexPath(row: nextIndex, section: 0), at: .left, animated: true)
    }
    
    func callback(_ signUpViewData: SignInRPModelData?) {
        if let refreshToken:String = signUpViewData?.token?.refreshToken {
            if let accessToken:String = signUpViewData?.token?.accessToken {
                UserDefaults.standard.setValue(accessToken, forKey: "accessToken")
                UserDefaults.standard.setValue(refreshToken, forKey: "refreshToken")
            }
        }
        navigationController?.popViewController(animated: true)
    }
    
    //정책 화면으로 이동
    func policyMove(policyFlag:Int) {
        let policyVC = StoryBoardName.policyStoryBoard.instantiateViewController(withIdentifier: "PolicyVC") as! PolicyVC
        
        policyVC.policyFlag = policyFlag
        navigationController?.pushViewController(policyVC, animated: true)
    }
}

extension SignUpVC: UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return signUpArr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if signUpArr[indexPath.row] == "nickname" {
            signUpNameCell = collectionView.dequeueReusableCell(withReuseIdentifier: "SignUpNameCell", for: indexPath) as? SignUpNameCell
            if let userInfo = userInfo {
                signUpNameCell?.nickNameTF.text = userInfo.nickname
                signUpNameCell?.nickNameTF.becomeFirstResponder()
            }
            
            signUpNameCell?.callingView = self as Any
            return signUpNameCell!
        }else if signUpArr[indexPath.row] == "birth" {
            signUpBirthCell = collectionView.dequeueReusableCell(withReuseIdentifier: "SignUpBirthCell", for: indexPath) as? SignUpBirthCell
            signUpBirthCell?.callingView = self as Any
            return signUpBirthCell!
        }else if signUpArr[indexPath.row] == "gender" {
            signUpGenderCell = collectionView.dequeueReusableCell(withReuseIdentifier: "SignUpGenderCell", for: indexPath) as? SignUpGenderCell
            signUpGenderCell?.callingView = self as Any
            return signUpGenderCell!
        }else {
            signUpAreaSettingCell = collectionView.dequeueReusableCell(withReuseIdentifier: "SignUpAreaSettingCell", for: indexPath) as? SignUpAreaSettingCell
            signUpAreaSettingCell?.callingView = self as Any
            return signUpAreaSettingCell!
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var width = CGFloat(0.0)
        var height = CGFloat(0.0)
        
        width = collectionView.frame.width
        height = collectionView.frame.height
        let size = CGSize(width: width, height: height)
        
        return size
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}
