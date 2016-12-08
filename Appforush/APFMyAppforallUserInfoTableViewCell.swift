//
//  APFMyPROJECTUserInfoTableViewCell.swift
//  PROJECT
//
//  Created by Sadjad Fouladi on 25/2/94.
//  Copyright (c) 1394 AP PROJECT. All rights reserved.
//

import UIKit

class APFMyPROJECTUserInfoTableViewCell: UITableViewCell {

    @IBOutlet weak var userAvatar: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userAccountStatus: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.contentView.frame = self.bounds
        self.contentView.autoresizingMask = [UIViewAutoresizing.FlexibleWidth, UIViewAutoresizing.FlexibleHeight]
        self.frame = self.bounds
        self.autoresizingMask = [UIViewAutoresizing.FlexibleWidth, UIViewAutoresizing.FlexibleHeight]
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    } 
    
}
