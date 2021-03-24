//
//  EditProfileViewController.swift
//  NnkOriginalApp
//
//  Created by 早司菜々花 on 2020/06/25.
//  Copyright © 2020 nanakahayashi. All rights reserved.
//

import UIKit
import NCMB
import NYXImagesKit

class EditProfileViewController: UIViewController,UISearchTextFieldDelegate,UITextViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    @IBOutlet var cansellButton : UIBarButtonItem!
    @IBOutlet var saveButton : UIBarButtonItem!
    @IBOutlet var userImageView : UIImageView!
    @IBOutlet var displayNameTextField : UITextField!
    @IBOutlet var introduceTextView : UITextView!
    @IBOutlet var editUserImageButton : UIButton!
    @IBOutlet var displayNameAlertLabel : UILabel!
    @IBOutlet var introduceAlertLabel : UILabel!
    
    var placeholder = UIImage(named: "placeholder2.png")!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        enableButton()
        displayNameTextField.delegate = self
        introduceTextView.delegate = self
        
        
        //ユーザーIDの取得、textfieldに代入
        let userID = NCMBUser.current()?.userName
        // userIdTextField.text = userID
        
        userImageView.layer.cornerRadius = userImageView.bounds.width/2.0
        userImageView.layer.masksToBounds = true
        
        //NCMBから情報を取得して表示
        if let user = NCMBUser.current(){
            displayNameTextField.text = user.object(forKey: "displayName") as? String
            introduceTextView.text = user.object(forKey: "introduction") as? String
            self.navigationItem.title = user.userName
            userImageView.image = placeholder
            
            //画像の表示
            let file = NCMBFile.file(withName:user.objectId, data:nil) as! NCMBFile
            
            file.getDataInBackground { (data, error) in
                if error != nil{
                    print(error)
                }else{
                    let image = UIImage(data: data!)
                    self.userImageView.image = image!
                }
            }
            
        }else{
            //NCMBUser.currentがnilの場合→162時間ログインしてなかった場合ログイン画面に戻る
            let storyboard = UIStoryboard(name:"Signin", bundle: Bundle.main)
            //一番最初の画面(ログイン画面)の取得
            let rootViewController = storyboard.instantiateViewController(withIdentifier: "RootNavigationController")
            
            UIApplication.shared.keyWindow?.rootViewController = rootViewController
            
            //ログイン状態の保持
            let ud = UserDefaults.standard
            ud.set(false,forKey: "isLogin")
            ud.synchronize()
        }
        
        //お名前の文字数のカウント
        let observable = displayNameTextField.rx.text.asObservable
        let subscription = observable()
            .subscribe(onNext: { string in
                let countNumber = self.displayNameTextField.text!.count
                if countNumber >= 0 && countNumber <= 15 {
                    self.displayNameAlertLabel.isHidden = true
                    self.enableButton()
                
                } else {
                    self.displayNameAlertLabel.isHidden = false
                    self.enableButton()
                    
                   
                }
                
            })
        
        //自己紹介の文字数のカウント
        let observable2 = introduceTextView.rx.text.asObservable
        let subscription2 = observable2()
            .subscribe(onNext: { string in
                let countNumber2 = self.introduceTextView.text!.count
                if countNumber2 >= 0 && countNumber2 <= 100 {
                    self.introduceAlertLabel.isHidden = true
                    self.enableButton()
                } else {
                    self.introduceAlertLabel.isHidden = false
                    self.enableButton()
                    
                   
                }
            })
    }
    
    func enableButton () {
        if displayNameAlertLabel.isHidden == true && introduceAlertLabel.isHidden == true {
            saveButton.isEnabled = true
        } else {
            saveButton.isEnabled = false
        }
    }
   
   
    
    
    
    //画面表示キーボードを反応
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        textView.resignFirstResponder()
        
        return true
    }
    
    
    

    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        //Uiimageとして取り出した情報を処理
        
        let selectedImage = info[UIImagePickerController.InfoKey(rawValue: UIImagePickerController.InfoKey.originalImage.rawValue)] as! UIImage
        
        print(selectedImage)
        //pickerを閉じる
        picker.dismiss(animated: true, completion: nil)
        
        var resizedImage = selectedImage.scale(byFactor: 0.1)
        

        let data = UIImage.pngData(resizedImage!)
      
        
        let file = NCMBFile.file(withName:NCMBUser.current().objectId, data:data()) as! NCMBFile
        
        file.saveInBackground({ (error) in
            if error != nil{
                print(error)
            }else{
                self.userImageView.image = resizedImage
                print("プロフィール画像の更新が完了",NCMBUser.current().objectId)
            }
            
        }) { (progress) in
            print(progress)
        }
        
        
    }
    
    @IBAction func selectImage(){
        let actionController = UIAlertController(title: "画像の選択", message: "選択してください", preferredStyle:.actionSheet)
        
        //カメラ起動
        let cameraAction = UIAlertAction(title: "カメラ", style: .default) { (action) in
            //カメラが使える場合のみ機能
            if UIImagePickerController.isSourceTypeAvailable(.camera){
                let picker = UIImagePickerController()
                //pickupのsourceはcameraですよ
                picker.sourceType = .camera
                picker.delegate = self
                self.present(picker, animated: true, completion: nil)
            }else{
                //カメラが使えないときのアラート
                let nonUseAlertController = UIAlertController(title: "注意", message: "この端末ではカメラは使えません", preferredStyle: .alert)
                let nonUseAlertAction = UIAlertAction(title: "OK", style: .default) { (action) in
                    nonUseAlertController.dismiss(animated: true, completion: nil)
                }
                nonUseAlertController.addAction(nonUseAlertAction)
                
                //ipad
                if UIDevice.current.userInterfaceIdiom == .pad {
                nonUseAlertController.popoverPresentationController?.sourceView = self.view
                let screenSize = UIScreen.main.bounds
                nonUseAlertController.popoverPresentationController?.sourceRect = CGRect(x: screenSize.size.width / 2,y: screenSize.size.height,width: 0,height: 0)
                }
                
                
                self.present(nonUseAlertController, animated: true, completion: nil)
            }
        }
        
        
        //アルバムから選択
        let albumAction = UIAlertAction(title: "アルバムから選択", style: .default) { (action) in
            let picker = UIImagePickerController()
            //pickupのsourceはphotolibralyですよ
            picker.sourceType = .photoLibrary
            picker.delegate = self
            self.present(picker, animated: true, completion: nil)
        }
        
        
        let cancellAction = UIAlertAction(title: "キャンセル", style: .cancel) { (action) in
            actionController.dismiss(animated: true, completion: nil)
        }
        
        actionController.addAction(cameraAction)
        actionController.addAction(albumAction)
        actionController.addAction(cancellAction)
        //actionControllerをこの画面から出しますよ！

        self.present(actionController, animated: true, completion: nil)
        
    }
    
    
    //キャンセルバーボタンアイテム
    @IBAction func backUserPage(){
        self.dismiss(animated: true, completion: nil)
    }
    
    //完了バーボタンアイテム
    @IBAction func saveUserInfo(){
        //NCMBに情報を保存
        let user = NCMBUser.current()
        user?.setObject(displayNameTextField.text, forKey: "displayName")
        user?.setObject(introduceTextView.text, forKey: "introduction")
        
        user?.saveInBackground({ (error) in
            if error != nil{
                print(error)
            }else{
                self.dismiss(animated: true, completion: nil)
            }
        })
    }
    
    
    
}
