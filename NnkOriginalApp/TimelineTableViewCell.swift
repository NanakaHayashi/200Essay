//
//  TimelineTableViewCell.swift
//  NnkOriginalApp
//
//  Created by 早司菜々花 on 2020/06/27.
//  Copyright © 2020 nanakahayashi. All rights reserved.
//

import UIKit

//セルの機能をviewcontrollewにdelegate
protocol TimelineTableViewCellDelegate {
    func didTapLikeButton(tableViewCell: UITableViewCell, button: UIButton)
    func didTapMenuButton(tableViewCell: UITableViewCell, button: UIButton)
    func didTapCommentsButton(tableViewCell: UITableViewCell, button: UIButton)
}

class TimelineTableViewCell: UITableViewCell {
    
     var delegate: TimelineTableViewCellDelegate?
    
       @IBOutlet var userNameLabel : UILabel!
       @IBOutlet var userImageView : UIImageView!
       @IBOutlet var postImageView : UIImageView!
       @IBOutlet var postTextView : UITextView!
       @IBOutlet var likeButton : UIButton!
       @IBOutlet var commentButton : UIButton!
       @IBOutlet var likeCountLabel : UILabel!
       @IBOutlet var postTimeLabel : UILabel!
       

    override func awakeFromNib() {
        
        userImageView.layer.cornerRadius = userImageView.bounds.width / 2.0
        userImageView.clipsToBounds = true
 
       
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    //いいねぼたん
       @IBAction func like(button: UIButton) {
           self.delegate?.didTapLikeButton(tableViewCell: self, button: button)
       }
       
       
       //メニューボタン
       @IBAction func openMenu(button: UIButton) {
           self.delegate?.didTapMenuButton(tableViewCell: self, button: button)
       }

       
       //コメントの表示
       @IBAction func showComments(button: UIButton) {
           self.delegate?.didTapCommentsButton(tableViewCell: self, button: button)
       }
    
   
    
    
}
