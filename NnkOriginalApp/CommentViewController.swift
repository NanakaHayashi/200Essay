//
//  CommentViewController.swift
//  NnkOriginalApp
//
//  Created by 早司菜々花 on 2020/06/30.
//  Copyright © 2020 nanakahayashi. All rights reserved.
//

import UIKit
import NCMB
import PKHUD

class CommentViewController: UIViewController,UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet private weak var tableView: UITableView!
    
    
    var postId: String!
    var comments = [Comment]()
    private var cellHeightList:[IndexPath:CGFloat] = [:]
    @IBOutlet var commentTableView: UITableView!
    var placeholder = UIImage(named: "placeholder2.png")!

    
    
    
     
    override func viewDidLoad() {
        super.viewDidLoad()
        
        commentTableView.dataSource = self
        commentTableView.delegate = self
        commentTableView.tableFooterView = UIView()

        commentTableView.rowHeight = UITableView.automaticDimension
        
        loadComments()
        
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
        
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")!
        let userImageView = cell.viewWithTag(1) as! UIImageView
        let userNameLabel = cell.viewWithTag(2) as! UILabel
        let commentLabel = cell.viewWithTag(3) as! UILabel
        // let createDateLabel = cell.viewWithTag(4) as! UILabel
        
       
        // ユーザー画像を丸く
        userImageView.layer.cornerRadius = userImageView.bounds.width / 2.0
        userImageView.layer.masksToBounds = true
        
        let user = comments[indexPath.row].user
        let userImagePath = "https://mbaas.api.nifcloud.com/2013-09-01/applications/sikn1AmFL0pGzGiI/publicFiles/" + user.objectId
        userImageView.kf.setImage(with: URL(string: userImagePath),placeholder:placeholder)
        userNameLabel.text = user.displayName
        commentLabel.text = comments[indexPath.row].text
        
        return cell
    }
    
    
    func loadComments() {
        comments = [Comment]()
        let query = NCMBQuery(className: "Comment")
        query?.whereKey("postId", equalTo: postId)
        query?.includeKey("user")
        
        query?.findObjectsInBackground({ (result, error) in
            if error != nil {
                HUD.flash(.error, delay: 1.0)
            } else {
                
                for commentObject in result as! [NCMBObject] {
                    // コメントをしたユーザーの情報を取得
                    let user = commentObject.object(forKey: "user") as! NCMBUser
                    let userModel = User(objectId: user.objectId, userName: user.userName)
                    userModel.displayName = user.object(forKey: "displayName") as? String
                    
                    // コメントの文字を取得
                    let text = commentObject.object(forKey: "text") as! String
                    
                    // Commentクラスに格納
                    let comment = Comment(postId: self.postId, user: userModel, text: text, createDate: commentObject.createDate)
                    self.comments.append(comment)
                    
                    // テーブルをリロード
                    self.commentTableView.reloadData()
                }
                
            }
        })
    }
    
    
    
    @IBAction func addComment() {
        let alert = UIAlertController(title: "コメント", message: "コメントを入力して下さい", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "キャンセル", style: .default) { (action) in
            alert.dismiss(animated: true, completion: nil)
        }
        let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
            
            alert.dismiss(animated: true, completion: nil)
            HUD.flash(.progress, delay: 1.0)
            let object = NCMBObject(className: "Comment")
            
            object?.setObject(self.postId, forKey: "postId")
            object?.setObject(NCMBUser.current(), forKey: "user")
            object?.setObject(alert.textFields?.first?.text, forKey: "text")
            
            object?.saveInBackground({ (error) in
                if error != nil {
                    HUD.flash(.error, delay: 1.0)
                } else {
                    HUD.flash(.success, delay: 1.0)
                    self.loadComments()
                }
            })
        }
        
        alert.addAction(cancelAction)
        alert.addAction(okAction)
        alert.addTextField { (textField) in
            textField.placeholder = "ここにコメントを入力"
        }
        
        //ipad
                       if UIDevice.current.userInterfaceIdiom == .pad {
                       alert.popoverPresentationController?.sourceView = self.view
                       let screenSize = UIScreen.main.bounds
                       alert.popoverPresentationController?.sourceRect = CGRect(x: screenSize.size.width / 2,y: screenSize.size.height,width: 0,height: 0)
                       }
        self.present(alert, animated: true, completion: nil)
    }

    
    
    
}




