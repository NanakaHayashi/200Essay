//
//  LoginViewController.swift
//  NnkOriginalApp
//
//  Created by 早司菜々花 on 2020/08/02.
//  Copyright © 2020 nanakahayashi. All rights reserved.
//

import UIKit
import NCMB

class LoginViewController: UIViewController,UITextFieldDelegate{

  @IBOutlet var userIdTextField : UITextField!
  @IBOutlet var passwordTextField : UITextField!
  
  override func viewDidLoad() {
      super.viewDidLoad()
      userIdTextField.delegate = self
      passwordTextField.delegate = self
  }
  
  //画面が立ち上げるとキーボードを出す
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
      textField.resignFirstResponder()
      return true
      
  }
  
  //ログイン
  @IBAction func signIn(){
      //もしtextFieldがnilだったらクラッシュするから保険のif文
      if userIdTextField.text != nil && passwordTextField.text != nil{
          //ログイン本命関数
          NCMBUser.logInWithUsername(inBackground: userIdTextField.text!, password: passwordTextField.text!) { (user, error) in
              if error != nil{
                  let failedSigninAlertController = UIAlertController(title: "失敗", message: "ログインできませんでした", preferredStyle: .alert)
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
              }else {
                let  activeInfo = NCMBUser.current()?.object(forKey: "active")
                    if activeInfo == nil{
                   
                 //ログイン成功、mainstoryboardに画面遷移
                  let storyboard = UIStoryboard(name:"Main", bundle: Bundle.main)
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
    
      
      
      
  
      
  }
    
    }

}
