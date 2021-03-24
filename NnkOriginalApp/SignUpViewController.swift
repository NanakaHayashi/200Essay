//
//  SignUpViewController.swift
//  NnkOriginalApp
//
//  Created by 早司菜々花 on 2020/06/24.
//  Copyright © 2020 nanakahayashi. All rights reserved.
//

import UIKit
import NCMB

class SignUpViewController: UIViewController,UITextFieldDelegate {
    
    @IBOutlet var userIdTextField : UITextField!
    @IBOutlet var mailTextField : UITextField!
    @IBOutlet var passwordTextField : UITextField!
    @IBOutlet var confirmPasswordTextField : UITextField!
    @IBOutlet var signUpButton : UIButton!
    
//    @IBOutlet var addressTextField : UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        userIdTextField.delegate = self
        mailTextField.delegate = self
        passwordTextField.delegate = self
        confirmPasswordTextField.delegate = self

        
        let date = Date()
              let dateForMatter = DateFormatter()
              
              dateForMatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "yyMd", options: 0, locale: Locale(identifier: "ja_JP"))
              
              print("日付です！！！！！！！！！",dateForMatter.string(from: date))
        
        signUpButton.layer.cornerRadius = 8.0
        signUpButton.layer.borderWidth = 5.0
        signUpButton.layer.borderColor = UIColor.white.cgColor
        
        
    }
    
    
       func textFieldShouldReturn(_ textField: UITextField) -> Bool {
           //画面を閉じるコード
           textField.resignFirstResponder()
           return true
       }
    
    
    
    
    @IBAction func signup(){
        
        let user = NCMBUser()
        user.userName = userIdTextField.text!
        user.mailAddress = mailTextField.text!
        
        let date = Date()
        let dateForMatter = DateFormatter()
        dateForMatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "yyMd", options: 0, locale: Locale(identifier: "ja_JP"))
        
        user.setObject(dateForMatter.string(from: date), forKey: "startedDate")
        print("日付が保存されました",dateForMatter.string(from: date))
        if passwordTextField.text == confirmPasswordTextField.text{
            user.password = passwordTextField.text!
        }else{
            print("パスワードの不一致です")
        }
        
        
        user.signUpInBackground { (error) in
            
            if error != nil{
                
                print(error)
                let failedSigninAlertController = UIAlertController(title: "失敗", message: "新規会員登録できませんでした", preferredStyle: .alert)
                let failedSigninAlertAction = UIAlertAction(title: "OK", style: .default) { (action) in
                    failedSigninAlertController.dismiss(animated: true, completion: nil)
                }
                failedSigninAlertController.addAction(failedSigninAlertAction)
                
                
                //ipad
                if UIDevice.current.userInterfaceIdiom == .pad {
                failedSigninAlertController.popoverPresentationController?.sourceView = self.view
                let screenSize = UIScreen.main.bounds
                failedSigninAlertController.popoverPresentationController?.sourceRect = CGRect(x: screenSize.size.width / 2,y: screenSize.size.height,width: 0,height: 0)
                }
                self.present(failedSigninAlertController, animated: true, completion: nil)
                
                
            }else{
                let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
                //一番最初の画面の取得
                let rootViewController = storyboard.instantiateViewController(withIdentifier: "RootTabBarController")
                
                UIApplication.shared.keyWindow?.rootViewController = rootViewController
                
                //ログイン状態の保持
                let ud = UserDefaults.standard
                ud.set(true,forKey: "isLogin")
                ud.synchronize()
            }
        }
        
        
    }

  
    @IBAction func url(){
        let url = NSURL(string: "https://qiita.com/masuhara/private/42bea0635e88529303fe")
        if UIApplication.shared.canOpenURL(url! as URL){
            UIApplication.shared.open(url! as URL, options: [:], completionHandler: nil)
        }
    }
    

}
