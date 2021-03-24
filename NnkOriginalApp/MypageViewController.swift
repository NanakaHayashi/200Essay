//
//  MypageViewController.swift
//  NnkOriginalApp
//
//  Created by 早司菜々花 on 2020/06/25.
//  Copyright © 2020 nanakahayashi. All rights reserved.
//

import UIKit
import NCMB
import PKHUD
import Kingfisher


class MypageViewController: UIViewController,UITableViewDelegate,UITableViewDataSource, TimelineTableViewCellDelegate {
  
    
    

    @IBOutlet var userImageView : UIImageView!
    @IBOutlet var postcountLabel : UILabel!
    @IBOutlet var introductionTextView : UITextView!
    @IBOutlet var postTableView : UITableView!
    @IBOutlet var showMenuButton : UIBarButtonItem!
    @IBOutlet var userDisplaynameLabel : UILabel!
    @IBOutlet var startedDateLabel : UILabel!
    @IBOutlet var timelineTableView :UITableView!
    
    var selectedPost: Post?
    var posts = [Post]()
    var placeholder = UIImage(named: "placeholder2.png")!
    var comments = [Comment]()
    var blockingUser = [NCMBUser]()
    var blockedUser = [NCMBUser]()
    var blockUserIdArray = [String]()
    var blockingUserArray = [String]()
    var currentUser = NCMBUser.current()
    var users = [NCMBUser]()
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        if let indexPathForSelectedRow = postTableView.indexPathForSelectedRow {
            postTableView.deselectRow(at: indexPathForSelectedRow, animated: true)
        }
        
        userImageView.layer.cornerRadius = userImageView.bounds.width / 3.0
        userImageView.clipsToBounds = true
        
        postTableView.delegate = self
        postTableView.dataSource = self

        
        //cellの読み込み
        let nib = UINib(nibName: "TimelineTableViewCell", bundle: Bundle.main)
        postTableView.register(nib, forCellReuseIdentifier: "Cell")
        
        //枠線を消す・cellの大きさの指定
        postTableView.tableFooterView = UIView()
        postTableView.rowHeight = 470
        
        let user = NCMBUser.self
               
               if let user = NCMBUser.current() {
                
                    if userDisplaynameLabel.text == "" {
                    userDisplaynameLabel.text = "NONAME"
                    }else{
                        user.object(forKey: "displayName") as? String
                    }

            
                   introductionTextView.text = user.object(forKey: "introduction") as? String
                   startedDateLabel.text = user.object(forKey: "startedDate") as? String
                   userImageView.image = placeholder
                   
                   
                   self.navigationItem.title = user.userName
                   
                   let file = NCMBFile.file(withName: user.objectId, data: nil) as! NCMBFile
                   file.getDataInBackground { (data, error) in
                       if error != nil {
                        print("画像の取得エラー")

                       } else {
                           if data != nil {
                               let image = UIImage(data: data!)
                               self.userImageView.image = image
                           }
                       }
                   }
               } else {
                // NCMBUser.current()がnilだったとき
                let storyboard = UIStoryboard(name: "Signin", bundle: Bundle.main)
                let rootViewController = storyboard.instantiateViewController(withIdentifier: "RootNavigationController")
                UIApplication.shared.keyWindow?.rootViewController = rootViewController
                
                // ログイン状態の保持
                let ud = UserDefaults.standard
                ud.set(false, forKey: "isLogin")
                ud.synchronize()
            }
        
        setRefreshControl()
         loadTimeline()

        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if let indexPathForSelectedRow = postTableView.indexPathForSelectedRow {
            postTableView.deselectRow(at: indexPathForSelectedRow, animated: true)
        }
        
        if let user = NCMBUser.current() {
            
            if userDisplaynameLabel.text == "" {
             userDisplaynameLabel.text = "NoName"
            }else{
             userDisplaynameLabel.text = user.object(forKey: "displayName") as? String
            }
            introductionTextView.text = user.object(forKey: "introduction") as? String
            startedDateLabel.text = user.object(forKey: "startedDate") as? String
            
            self.navigationItem.title = user.userName
            
            let file = NCMBFile.file(withName: user.objectId, data: nil) as! NCMBFile
            file.getDataInBackground { (data, error) in
                if error != nil {
                    print("画像の取得エラー")
                } else {
                    if data != nil {
                        let image = UIImage(data: data!)
                        self.userImageView.image = image
                    }
                }
            }
        } else {
            // NCMBUser.current()がnilだったとき
            let storyboard = UIStoryboard(name: "SignIn", bundle: Bundle.main)
            let rootViewController = storyboard.instantiateViewController(withIdentifier: "RootNavigationController")
            UIApplication.shared.keyWindow?.rootViewController = rootViewController
            
            // ログイン状態の保持
            let ud = UserDefaults.standard
            ud.set(false, forKey: "isLogin")
            ud.synchronize()
        }
        
        loadTimeline()
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
           return posts.count
       }
    
    //コメント画面遷移
       override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
           if segue.identifier == "toComments" {
               let commentViewController = segue.destination as! CommentViewController
               commentViewController.postId = selectedPost?.objectId
           }
       }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
        print(posts.count,"マイページのセルの数の取得")
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! TimelineTableViewCell
                   
                   cell.delegate = self
                   cell.tag = indexPath.row

        let user = posts[indexPath.row].user
        if cell.userNameLabel.text == ""{
            cell.userNameLabel.text = "NoName"
        }else{
             cell.userNameLabel.text = user.displayName
        }
                  
                   cell.postTimeLabel.text = posts[indexPath.row].posttime
                    print(posts[indexPath.row].posttime,"マイページのポストタイムの出力")
                   print(user.displayName,"userのお名前の出力")
                   
              //ユーザーアイコン
                   let userImageUrl = "https://mbaas.api.nifcloud.com/2013-09-01/applications/sikn1AmFL0pGzGiI/publicFiles/" + user.objectId
                   cell.userImageView.kf.setImage(with: URL(string: userImageUrl),placeholder:placeholder)
                    print(userImageUrl,"userアイコンの読み込み")

                //テキスト
                   cell.postTextView.text = posts[indexPath.row].text
                
                //画像
                   let imageUrl = posts[indexPath.row].imageUrl
                   cell.postImageView.kf.setImage(with: URL(string: imageUrl))
                       
                   print(imageUrl,"postimageの出力")

                   // Likeによってハートの表示を変える
                   if posts[indexPath.row].isLiked == true {
                       cell.likeButton.setImage(UIImage(named: "heartfill.png"), for: .normal)
                   } else {
                       cell.likeButton.setImage(UIImage(named: "heart.png"), for: .normal)
                   }

//                    Likeの数
                   cell.likeCountLabel.text = "\(posts[indexPath.row].likeCount)"
        
                   let postsObject = NCMBObject(className: "Post")
        
                //ポストタイム
                   cell.postTimeLabel.text = postsObject?.object(forKey: "posttime") as? String
        
                        
                    print("投稿した日の取得",postsObject?.object(forKey: "posttime"))

                   
                   return cell
    }
    
    
    
    
   
    
    
    @IBAction func showMenu() {
           let alertController = UIAlertController(title: "メニュー", message: "メニューを選択して下さい。", preferredStyle: .actionSheet)
           
        //ログアウト
           let signOutAction = UIAlertAction(title: "ログアウト", style: .default) { (action) in
               NCMBUser.logOutInBackground({ (error) in
                   if error != nil {
                       
                   } else {
                       // ログアウト成功
                       let storyboard = UIStoryboard(name: "Signin", bundle: Bundle.main)
                       let rootViewController = storyboard.instantiateViewController(withIdentifier: "RootNavigationController")
                       UIApplication.shared.keyWindow?.rootViewController = rootViewController
                       
                       // ログイン状態の保持
                       let ud = UserDefaults.standard
                       ud.set(false, forKey: "isLogin")
                       ud.synchronize()
                   }
               })
           }
           
        //退会
           let deleteAction = UIAlertAction(title: "退会", style: .default) { (action) in
               
            //退会確認アラート
               let alert = UIAlertController(title: "会員登録の解除", message: "本当に退会しますか？退会した場合、再度このアカウントをご利用頂くことができません。", preferredStyle: .alert)
               let okAction = UIAlertAction(title: "OK", style: .default, handler: { (action) in
                   // ユーザーのアクティブ状態をfalseに
                   if let user = NCMBUser.current() {
                       user.setObject(false, forKey: "active")
                    
                       user.saveInBackground({ (error) in
                           if error != nil {
                            HUD.flash(.error, delay: 1.0)
                            
                           } else {
                               // userのアクティブ状態を変更できたらログイン画面に移動
                               let storyboard = UIStoryboard(name: "Signin", bundle: Bundle.main)
                               let rootViewController = storyboard.instantiateViewController(withIdentifier: "RootNavigationController")
                            
                        //rootviewcontroller（＝一番前の画面）にrootnavigationcontrollerを載せる
                               UIApplication.shared.keyWindow?.rootViewController = rootViewController
                               
                               // ログイン状態の保持
                               let ud = UserDefaults.standard
                               ud.set(false, forKey: "isLogin")
                               ud.synchronize()
                           }
                       })
                   } else {
                       // userがnilだった場合ログイン画面に移動
                       let storyboard = UIStoryboard(name: "Signin", bundle: Bundle.main)
                       let rootViewController = storyboard.instantiateViewController(withIdentifier: "RootNavigationController")
                    
                    //rootviewcontroller（＝一番前の画面）にrootnavigationcontrollerを載せる
                       UIApplication.shared.keyWindow?.rootViewController = rootViewController
                       
                       // ログイン状態の保持
                       let ud = UserDefaults.standard
                       ud.set(false, forKey: "isLogin")
                       ud.synchronize()
                   }
                   
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
           
        //プロフィールの編集
           let  profileEditAction = UIAlertAction(title: "プロフィールの編集", style: .default) { (action) in
             self.performSegue(withIdentifier: "toEditProfile", sender: nil)
            }
        
           let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel) { (action) in
               alertController.dismiss(animated: true, completion: nil)
           }
           
           alertController.addAction(signOutAction)
           alertController.addAction(deleteAction)
           alertController.addAction(cancelAction)
           alertController.addAction(profileEditAction)
        
        //ipad
                       if UIDevice.current.userInterfaceIdiom == .pad {
                       alertController.popoverPresentationController?.sourceView = self.view
                       let screenSize = UIScreen.main.bounds
                       alertController.popoverPresentationController?.sourceRect = CGRect(x: screenSize.size.width / 2,y: screenSize.size.height,width: 0,height: 0)
                                               }
           
           self.present(alertController, animated: true, completion: nil)
       }
    
    
    func setRefreshControl() {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(reloadTimeline(refreshControl:)), for: .valueChanged)
        timelineTableView.addSubview(refreshControl)
    }
    
    @objc func reloadTimeline(refreshControl: UIRefreshControl) {
        refreshControl.beginRefreshing()
        // 更新が早すぎるので2秒遅延させる
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            refreshControl.endRefreshing()
        }
    }
    
    
    
    //コメントボタンを押した時、コメント画面に画面遷移
    func didTapCommentsButton(tableViewCell: UITableViewCell, button: UIButton) {
        // 選ばれた投稿を一時的に格納
        selectedPost = posts[tableViewCell.tag]
        
        // 遷移させる(このとき、prepareForSegue関数で値を渡す)
        self.performSegue(withIdentifier: "toComments", sender: nil)
    }
    
    
    //メニューボタン
    func didTapMenuButton(tableViewCell: UITableViewCell, button: UIButton) {
          let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
          
              //削除ボタン
             let deleteAction = UIAlertAction(title: "削除する", style: .destructive) { (action) in
                 HUD.flash(.success)
                 let query = NCMBQuery(className: "Post")
                 query?.getObjectInBackground(withId: self.posts[tableViewCell.tag].objectId, block: { (post, error) in
                     if error != nil {
                      HUD.flash(.labeledError(title: "削除できませんでした", subtitle: "もう一度やり直して下さい"))
                     } else {
                         // 取得した投稿オブジェクトを削除
                         post?.deleteInBackground({ (error) in
                             if error != nil {
                              HUD.flash(.labeledError(title: "削除できませんでした", subtitle:"もう一度やり直して下さい"))
                             } else {
                                 // 再読込
                                 self.loadTimeline()
                             }
                         })
                     }
                 })
             }
          
              //通報ボタン
              let reportAction = UIAlertAction(title: "報告する", style: .destructive) { (action) in
                  HUD.flash(.labeledSuccess(title: "報告しました", subtitle: "ご協力ありがとうございます"))
                 }
              //キャンセルボタン
                 let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel) { (action) in
                     alertController.dismiss(animated: true, completion: nil)
                 }
              //自分の投稿には削除ボタンを、他人の投稿には報告ボタンを表示
                 if posts[tableViewCell.tag].user.objectId == NCMBUser.current().objectId {
                     // 自分の投稿なので、削除ボタンを出す
                     alertController.addAction(deleteAction)
                 } else {
                     // 他人の投稿なので、報告ボタンを出す
                     alertController.addAction(reportAction)
                 }
                 alertController.addAction(cancelAction)
          //ipad
                 if UIDevice.current.userInterfaceIdiom == .pad {
                 alertController.popoverPresentationController?.sourceView = self.view
                 let screenSize = UIScreen.main.bounds
                 alertController.popoverPresentationController?.sourceRect = CGRect(x: screenSize.size.width / 2,y: screenSize.size.height,width: 0,height: 0)
                  
              }
          
                 self.present(alertController, animated: true, completion: nil)
      }
    
 
    
    
    func loadTimeline(){
    
    let query = NCMBQuery(className: "Post")
    
    //タイムラインを上から並べる
    query?.order(byDescending: "createDate")
    
    // 投稿したユーザーの情報も同時取得
    query?.includeKey("user")
        
        query?.whereKey("user", equalTo: NCMBUser.current())
    
    // オブジェクトの取得
    query?.findObjectsInBackground({ (result, error) in
        if error != nil {
            HUD.flash(.error, delay: 1.0)
        } else {
            // 投稿を格納しておく配列を初期化(これをしないとreload時にappendで二重に追加されてしまう)
            self.posts = [Post]()
            //postobjectを毎回ロード
            for postObject in result as! [NCMBObject] {
                // ユーザー情報をUserクラスにセ
                
                let user = postObject.object(forKey: "user") as! NCMBUser
                
                // 退会済みユーザーの投稿を避けるため、activeがfalse以外のモノだけを表示
                if user.object(forKey: "active") as? Bool != false {
                    
                    
                    // 投稿したユーザーの情報をUserモデルにまとめる
                    let userModel = User(objectId: user.objectId, userName: user.userName)
                    userModel.displayName = user.object(forKey: "displayName") as? String
                    
                    
                    let blockindUsersIdOfCurrentUser = self.currentUser?.object(forKey: "blockingUserId") as? [String] ?? [""]
                    print("blockindUsersIdOfCurrentUser",blockindUsersIdOfCurrentUser)
                    let blocedUsersIdOfCurrentUser = self.currentUser!.object(forKey: "blockedUserId") as? [String] ?? [""]
                    
                    //自分がブロックしてない　& 相手も自分をブロックしてなかったら！（）
                    if !(blockindUsersIdOfCurrentUser.contains(user.objectId)) && !(blocedUsersIdOfCurrentUser.contains((user.objectId)!)) {
                        userModel.displayName = self.currentUser!.object(forKey: "displayName") as? String
                    
                    // 投稿の情報を取得
                    let imageUrl = postObject.object(forKey: "imageUrl") as! String
                    let text = postObject.object(forKey: "text") as! String
                   
                    //posttimeのデータを取り出す
                    let posttime = postObject.object(forKey: "posttime") as? String
                        
                    // 2つのデータ(投稿情報と誰が投稿したか?)を合わせてPostクラスにセット
                    let post = Post(objectId: postObject.objectId, user: userModel, imageUrl: imageUrl, text: text, createDate: postObject.createDate,posttime:posttime!)
                    
                    // likeの状況(自分が過去にLikeしているか？)によってデータを挿入
                    let likeUsers = postObject.object(forKey: "likeUser") as? [String]
                    if likeUsers?.contains(NCMBUser.current().objectId) == true {
                        post.isLiked = true
                    } else {
                        post.isLiked = false
                    }
                    
                    // いいねの件数
                    if let likes = likeUsers {
                        post.likeCount = likes.count
                    }
                    
                    
                    // 配列に加える
                    //appendする時に、ブロックユーザーがnilであったらappendされるようにしている
                    if self.blockUserIdArray.firstIndex(of: post.user.objectId) == nil {
                    self.posts.append(post)
                        self.postcountLabel.text = String(self.posts.count)
                    print(self.posts.count)}
                }
            }
            }
            
            // 投稿のデータが揃ったらTableViewをリロード
            self.timelineTableView.reloadData()
            }
    })
    }
    
    func didTapLikeButton(tableViewCell: UITableViewCell, button: UIButton) {
          print("didtaplikebutton")
          //もしpostがいいねされなかったら　または　nilであれば
          if posts[tableViewCell.tag].isLiked == false || posts[tableViewCell.tag].isLiked == nil {
              let query = NCMBQuery(className: "Post")
              query?.getObjectInBackground(withId: posts[tableViewCell.tag].objectId, block: { (post, error) in
                  
                  //自分のobjectidを一つだけlikeuserのリストに入れる？
                  post?.addUniqueObject(NCMBUser.current().objectId, forKey: "likeUser")
                  post?.saveEventually({ (error) in
                      if error != nil {
                          HUD.flash(.error, delay: 1.0)
                      } else {
                          self.loadTimeline()
                      }
                  })
              })
          } else {
              let query = NCMBQuery(className: "Post")
              query?.getObjectInBackground(withId: posts[tableViewCell.tag].objectId, block: { (post, error) in
                  if error != nil {
                   
                    
                  } else {
                      //いいねぼたんの解除、likeuserのリストから削除
                      post?.removeObjects(in: [NCMBUser.current().objectId], forKey: "likeUser")
                      post?.saveEventually({ (error) in
                          if error != nil {
                              HUD.flash(.error, delay: 1.0)
                          } else {
                              self.loadTimeline()
                          }
                      })
                  }
              })
          }
      }
    
 


}
