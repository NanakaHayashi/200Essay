//
//  PostViewController.swift
//  NnkOriginalApp
//
//  Created by 早司菜々花 on 2020/06/27.
//  Copyright © 2020 nanakahayashi. All rights reserved.
//

import UIKit
import NYXImagesKit
import NCMB
import UITextView_Placeholder
import PKHUD
import RxCocoa
import RxSwift

class PostViewController: UIViewController,UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextViewDelegate  {

    
    let placeholderImage = UIImage(named:"placeholder2.png")
    let postholderImage = UIImage(named: "imageholder3_60.png")
    var resizedImage: UIImage!
    
    @IBOutlet var postImageView: UIImageView!
    @IBOutlet var postTextView: UITextView!
    @IBOutlet var postBarButtonItem: UIBarButtonItem!
    @IBOutlet var postCountLabel : UILabel!
    @IBOutlet var alertlabel : UILabel!
    @IBOutlet var imagePickerButton : UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        postImageView.image = postholderImage
        postBarButtonItem.isEnabled = false
        postTextView.placeholder = "キャプションをかく"
        postTextView.delegate = self
        
        self.postTextView.delegate = self
        
        
        //文字数のカウント
        let observable = postTextView.rx.text.asObservable
        let subscription = observable()
        .subscribe(onNext: { string in
            let countNumber = self.postTextView.text.count
            if countNumber >= 0 && countNumber <= 200 {
                self.postCountLabel.textColor = UIColor.black
                self.postCountLabel.text = String(countNumber)
                self.alertlabel.isHidden = true
            } else {
                self.postCountLabel.textColor = UIColor.red
                self.postCountLabel.text = String(countNumber)
                self.alertlabel.isHidden = false
            }
            
        })
        
        imagePickerButton.layer.cornerRadius = 8.0
        imagePickerButton.layer.borderWidth = 5.0
        imagePickerButton.layer.borderColor = UIColor.white.cgColor
        
       
        
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        textView.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if (self.postTextView.isFirstResponder) {
            self.postTextView.resignFirstResponder()
        }
    }
    
    
    
    func textViewDidChange(_ textView: UITextView) {
        confirmContent()
      }
    
       func imagePickerController
           (_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
           
           let seletedImage = info[.originalImage] as! UIImage
           
           resizedImage = seletedImage.scale(byFactor: 0.2)
           //代入
           postImageView.image = resizedImage
           
           picker.dismiss(animated: true, completion: nil)
           
           
           confirmContent()
           
           print("画像の読み込みに成功")
          
       }
    
    
    
    //画像選択のアラート
    @IBAction func selectImage() {
        
          let alertController = UIAlertController(title: "画像選択", message: "画像を選択してください", preferredStyle: .actionSheet)

          let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel) { (action) in
              alertController.dismiss(animated: true, completion: nil)
          }

          let cameraAction = UIAlertAction(title: "カメラで撮影", style: .default) { (action) in
              // カメラ起動
              if UIImagePickerController.isSourceTypeAvailable(.camera) == true {
                  let picker = UIImagePickerController()
                  picker.sourceType = .camera
                  picker.delegate = self
                  self.present(picker, animated: true, completion: nil)
              } else {
                  print("この機種ではカメラが使用出来ません。")
              }
          }

          let photoLibraryAction = UIAlertAction(title: "フォトライブラリから選択", style: .default) { (action) in
              // アルバム起動
              if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) == true {
                  let picker = UIImagePickerController()
                  picker.sourceType = .photoLibrary
                  picker.delegate = self
                  self.present(picker, animated: true, completion: nil)
              } else {
                  print("この機種ではフォトライブラリが使用出来ません。")
              }
          }

          alertController.addAction(cancelAction)
          alertController.addAction(cameraAction)
          alertController.addAction(photoLibraryAction)
        
        //ipad
                              if UIDevice.current.userInterfaceIdiom == .pad {
                              alertController.popoverPresentationController?.sourceView = self.view
                              let screenSize = UIScreen.main.bounds
                              alertController.popoverPresentationController?.sourceRect = CGRect(x: screenSize.size.width / 2,y: screenSize.size.height,width: 0,height: 0)
                              }
          self.present(alertController, animated: true, completion: nil)
        
       
        
        
      }
    
    
    
    
    
    
    @IBAction func sharePhoto() {
      

    // 撮影した画像をデータ化したときに右に90度回転してしまう問題の解消
        UIGraphicsBeginImageContext(resizedImage.size)
        let rect = CGRect(x: 0, y: 0, width: resizedImage.size.width, height: resizedImage.size.height)
        resizedImage.draw(in: rect)
        resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        //UIImage→pngdata
        let data = UIImage.pngData(resizedImage)
        
    // pngデータをfileに変換
        let file = NCMBFile.file(with: data()) as! NCMBFile
        
    //アップロード
        file.saveInBackground({ (error) in
        if error != nil {
            //エラー出たときのアラート
            let alert = UIAlertController(title: "画像アップロードエラー", message: error!.localizedDescription, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: { (action) in
                alert.dismiss(animated: true, completion: nil)
            })
            alert.addAction(okAction)
            
            //ipad
            if UIDevice.current.userInterfaceIdiom == .pad {
            alert.popoverPresentationController?.sourceView = self.view
            let screenSize = UIScreen.main.bounds
            alert.popoverPresentationController?.sourceRect = CGRect(x: screenSize.size.width / 2,y: screenSize.size.height,width: 0,height: 0)
            }
            
            self.present(alert, animated: true, completion: nil)
            
            }
        else {
            // 画像アップロードが成功
            let postObject = NCMBObject(className: "Post")

            if self.postTextView.text.count >= 200 {
                print("200文字を超えています")
                
                return
            }
            
            
            let date = Date()
            let dateForMatter = DateFormatter()
            dateForMatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "yyyyMdHm", options: 0, locale: Locale(identifier: "ja_JP"))
            
             postObject?.setObject(dateForMatter.string(from: date), forKey: "posttime")
             postObject?.setObject(self.postTextView.text!, forKey: "text")
             postObject?.setObject(NCMBUser.current(), forKey: "user")
            
            
            let url = "https://mbaas.api.nifcloud.com/2013-09-01/applications/sikn1AmFL0pGzGiI/publicFiles/" + file.name
            
            postObject?.setObject(url, forKey: "imageUrl")
            
            //アップロード
            postObject?.saveInBackground({ (error) in
                    if error != nil {
                        HUD.flash(.error, delay:1.0)
                   } else {
                      
                    if self.postTextView.text.count <= 200{
                        HUD.flash(.progress, delay: 1.0)
                        self.postImageView.image = nil
                        self.postImageView.image = self.postholderImage
                        self.postTextView.text = nil
                        self.tabBarController?.selectedIndex = 0
                        print("アップロード完了",error)
                        HUD.flash(.success, delay: 1.0)}
                        else{
                            print("200文字超えたからアップロードできないよ")
                            print(error)
                           
                            
                        }
                        
                        
                            }
                        })
                    }
                }) { (progress) in
                    self.postBarButtonItem.isEnabled = false
                    print(progress)
                }
            }
    
       
    
    
        func confirmContent() {
            if postTextView.text.count > 0 && postTextView.text.count <= 200 && postImageView.image != postholderImage {
            postBarButtonItem.isEnabled = true
        } else {
            postBarButtonItem.isEnabled = false
        }
        }
    
    

        @IBAction func cancel() {
            
        if postTextView.isFirstResponder == true {
            postTextView.resignFirstResponder()
        }

        let alert = UIAlertController(title: "投稿内容の破棄", message: "入力中の投稿内容を破棄しますか？", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: { (action) in
            self.postTextView.text = nil
            self.postImageView.image = self.postholderImage
            self.confirmContent()
            
            
        })
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
        })
        alert.addAction(okAction)
        alert.addAction(cancelAction)
            
            //ipad
            if UIDevice.current.userInterfaceIdiom == .pad {
            alert.popoverPresentationController?.sourceView = self.view
            let screenSize = UIScreen.main.bounds
            alert.popoverPresentationController?.sourceRect = CGRect(x: screenSize.size.width / 2,y: screenSize.size.height,width: 0,height: 0)
            }
            
        self.present(alert, animated: true, completion: nil)
    }



    


}

