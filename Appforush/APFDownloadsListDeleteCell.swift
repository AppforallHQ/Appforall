//
//  APFDownloadsListTableViewCell.swift
//
//
//  Created by Sadjad Fouladi on 24/1/94.
//
//

import UIKit


class APFDownloadsListDeleteCell: UITableViewCell {
    
    @IBOutlet weak var deleteButton: UIButton!
    
    // Fuck it.
    override var frame: CGRect {
        get {
            return super.frame
        }
        
        set(_frame) {
            var f = _frame
            
            f.origin.x += 8.0
            f.origin.y += 8.0
            f.size.width -= 16.0
            f.size.height -= 8.0
            
            super.frame = f
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        //let bgView = UIImageView(image: UIImage(named: "AppBg"))
        //self.backgroundView = bgView
        
        self.deleteButton.transform = CGAffineTransformMakeScale(-1.0, 1.0);
        self.deleteButton.titleLabel!.transform = CGAffineTransformMakeScale(-1.0, 1.0);
        self.deleteButton.imageView!.transform = CGAffineTransformMakeScale(-1.0, 1.0);
        self.deleteButton.layer.cornerRadius = 3.0
        
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
