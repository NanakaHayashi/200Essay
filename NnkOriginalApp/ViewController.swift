//
//  ViewController.swift
//  NnkOriginalApp
//
//  Created by 早司菜々花 on 2020/06/23.
//  Copyright © 2020 nanakahayashi. All rights reserved.
//

import UIKit
import NCMB
import Kingfisher
import PKHUD

class ViewController: UIViewController,UITableViewDataSource,UITableViewDelegate,TimelineTableViewCellDelegate {
    
    
    var selectedPost: Post?
    var posts = [Post]()
    var followings = [NCMBUser]()
    var placeholder = UIImage(named: "placeholder2.png")!
    var comments = [Comment]()
    var currentUser = NCMBUser.current()
    var blockUserIdArray = [String]()
    var blockingUserArray = [String]()
    var blockingUser = [NCMBUser]()
    var blockedUser = [NCMBUser]()
    var users = [NCMBUser]()
    

    
    
    @IBOutlet var timelineTableView :UITableView!
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        timelineTableView.delegate = self
        timelineTableView.dataSource = self
        
        //cellの読み込み
        let nib = UINib(nibName: "TimelineTableViewCell", bundle: Bundle.main)
        timelineTableView.register(nib, forCellReuseIdentifier: "Cell")
        
        //枠線を消す・cellの大きさの指定
        timelineTableView.tableFooterView = UIView()
        timelineTableView.rowHeight = 440
        
        // 引っ張って更新
        setRefreshControl()
        
        loadTimeline()
        
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        loadTimeline()
    }
    
    
    //コメント画面遷移
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toComments" {
            let commentViewController = segue.destination as! CommentViewController
            commentViewController.postId = selectedPost?.objectId
        }
    }
    
    
    //個数
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(posts.count,"ポストの数")
        return posts.count
    }
    
    //内容
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! TimelineTableViewCell
        
        cell.delegate = self
        cell.tag = indexPath.row
        print("菜々花あああああああああ",posts[indexPath.row].user)
        let user = posts[indexPath.row].user
        
        let postsObject = NCMBObject(className: "Post")
        cell.userNameLabel.text = user.displayName
        
        if cell.userNameLabel.text == "" {
            cell.userNameLabel.text = "NoName"
        }
        
        cell.postTimeLabel.text = postsObject?.object(forKey: "posttime") as? String
        cell.postTimeLabel.text = posts[indexPath.row].posttime
        
        
        let file = NCMBFile.file(withName: user.objectId, data: nil) as! NCMBFile
         file.getDataInBackground { (data, error) in
              if data != nil{
                  let image = UIImage(data: data!)
                  cell.userImageView.image = image
              }
        }

        
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
        
        // Likeの数
        cell.likeCountLabel.text = "\(posts[indexPath.row].likeCount)"

        return cell
    }
    
    
    
    //①いいね機能
    func didTapLikeButton(tableViewCell: UITableViewCell, button: UIButton) {
        
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
                    HUD.flash(.error, delay: 1.0)
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
    
    
    //②投稿みぎうえのメニューボタン
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
    
                let query = NCMBQuery(className: "Post")
                    query?.getObjectInBackground(withId: self.posts[tableViewCell.tag].objectId, block: { (post, error) in
                              post?.saveEventually({ (error) in
                                  if error != nil {
                                      HUD.flash(.error, delay: 1.0)
                                        print("通報ができませんでした")
                                    
                                  } else {
                                    //自分のobjectidを一つだけpostクラスのreportに入れる
                                    post?.addUniqueObject(NCMBUser.current().objectId, forKey: "report")
                                    
                                    //Reportクラスにポストidと自分のidを入れる
                                    let object = NCMBObject(className: "Report") //新たにクラス作る
                                    object?.setObject(self.posts[tableViewCell.tag].objectId, forKey: "reportId")
                                    object?.setObject(NCMBUser.current(), forKey: "user")
                                    object?.saveInBackground({ (error) in
                                       if error != nil {
                                        HUD.flash(.labeledError(title: "エラーです", subtitle: ""))
                                       } else {
                                       HUD.flash(.labeledSuccess(title: "報告しました", subtitle: ""), delay: 1.0)
                                       }
                                     })
                                    self.loadTimeline()
                                    print("通報が完了")
                                  }
                              })
                          })
               
               }
        
        let blockUserAction = UIAlertAction(title: "ブロック", style: .default) { (action) in
        
            let user = NCMBUser.current()
        
            //post側の情報をUserクラスのblockingUserIdとして保存
            user?.addUniqueObject(self.posts[tableViewCell.tag].user.objectId, forKey: "blockingUserId")
            user?.saveInBackground({ (error) in
            if error != nil {
                print(error)
            } else {

                let query = NCMBUser.query()
                query?.whereKey("objectId", equalTo: self.posts[tableViewCell.tag].user.objectId)
                query?.findObjectsInBackground({ (reslt, error) in
                    if error != nil {
                        print("ブロック失敗")
                    } else {
                        //
                        let blockedUsers = reslt as! [NCMBUser]
                        let blockedUser = blockedUsers[0]
                        
                        HUD.flash(.labeledSuccess(title: "ブロックしました", subtitle: "次回からタイムラインに表示しません"), delay: 1.0)
                        
                        self.setRefreshControl()
                        
                        //ブロックされた側のUserクラスに自分のidがBlockedUserIdとして保存される
                        blockedUser.addUniqueObject(NCMBUser.current()?.objectId, forKey: "blockedUserId")
                        blockedUser.saveInBackground { (error) in
                            if error != nil {
                                print("ブロック失敗")
                            }
                        }
                        
                    }
                })
            }
        })
        
        }
            
        
      //キャンセルボタン
      let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel) { (action) in
                   alertController.dismiss(animated: true, completion: nil)
        }
        
       //自分の投稿には削除ボタンを、他人の投稿には報告ボタンを表示
        if self.posts[tableViewCell.tag].user.objectId == NCMBUser.current().objectId {
                   // 自分の投稿なので、削除ボタンを出す
                   alertController.addAction(deleteAction)
               } else {
                   // 他人の投稿なので、報告ボタンを出す
                   alertController.addAction(reportAction)
                   alertController.addAction(blockUserAction)
                
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
    
    
    
    
    //③コメントボタンを押した時、コメント画面に画面遷移
    func didTapCommentsButton(tableViewCell: UITableViewCell, button: UIButton) {
        // 選ばれた投稿を一時的に格納
        selectedPost = posts[tableViewCell.tag]
        
        // 遷移させる(このとき、prepareForSegue関数で値を渡す)
        self.performSegue(withIdentifier: "toComments", sender: nil)
    }
  
    
    
    
    func loadTimeline(){
        
        let query = NCMBQuery(className: "Post")
        
        //タイムラインを上から並べる
        query?.order(byDescending: "createDate")
        
        // 投稿したユーザーの情報も同時取得
        query?.includeKey("user")
        
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
                    
//                    let object = NCMBObject(className: "Post")
//                    let user = object?.object(forKey: "user") as! NCMBUser
                    let user = postObject.object(forKey: "user") as! NCMBUser
//
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
                        self.posts.append(post)
                            
                        
                    }
                }
                }
                
                // 投稿のデータが揃ったらTableViewをリロード
                self.timelineTableView.reloadData()
                }
        })
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
    
    
    
    
    
    
    
}


