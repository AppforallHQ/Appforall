//
//  APFDownloadsListTableViewCell.swift
//  
//
//  Created by Sadjad Fouladi on 24/1/94.
//
//

import UIKit

enum DownloadState {
    case Downloading
    case Successful
    case Failed
}

class APFDownloadsListTableViewCell: UITableViewCell {

    @IBOutlet weak var appNameLabel: UILabel!
    @IBOutlet weak var downloadPercentageLabel: UILabel!
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var fileSizeLabel: UILabel!
    @IBOutlet weak var downloadStateIcon: UIImageView!
    @IBOutlet weak var appIcon : UIImageView!
    
    @IBOutlet weak var activityIndicator : UIActivityIndicatorView!
    
    private var _progress: Float = 0.0
    private var _downloaded: UInt64 = 0
    private var _total: UInt64 = 1
    private var _state: DownloadState = DownloadState.Downloading
    
    func loading()
    {
        self.appNameLabel.hidden = true
        self.downloadPercentageLabel.hidden = true
        self.progressBar.hidden = true
        self.fileSizeLabel.hidden = true
        self.downloadStateIcon.hidden = true
        self.appIcon.hidden = true
        self.activityIndicator.hidden = false
        self.activityIndicator.startAnimating()
    }
    
    func enable()
    {
        self.appNameLabel.hidden = false
        self.downloadPercentageLabel.hidden = false
        self.progressBar.hidden = false
        self.fileSizeLabel.hidden = false
        self.downloadStateIcon.hidden = false
        self.appIcon.hidden = false
        self.activityIndicator.hidden = true
        self.activityIndicator.stopAnimating()
        
    }
    
    var appName: String {
        get {
            return self.appNameLabel.text!
        }
        
        set(name) {
            self.appNameLabel.text = name
        }
    }
    
    var progress: Float {
        get {
            return _progress
        }
        set(prog) {
            _progress = prog
            
            if self.downloadPercentageLabel != nil {
                self.downloadPercentageLabel.text = String(format: "%.1f%%", _progress * 100)
                self.downloadPercentageLabel.hidden = false
            }
            
            if self.progressBar != nil {
                self.progressBar.progress = _progress
            }
            
            _downloaded = UInt64(_progress * Float(_total))
            
            if self._state == DownloadState.Downloading {
                self.fileSizeLabel.text = String(format: "%@ / %@", NSByteCountFormatter.stringFromByteCount(Int64(_downloaded), countStyle: NSByteCountFormatterCountStyle.File), NSByteCountFormatter.stringFromByteCount(Int64(_total), countStyle: NSByteCountFormatterCountStyle.File))
            }
            else {
                self.fileSizeLabel.text = String(format: "%@", NSByteCountFormatter.stringFromByteCount(Int64(_total), countStyle: NSByteCountFormatterCountStyle.File))
            }
        }
    }
    
    var total: UInt64 {
        get {
            return _total
        }
        
        set(total) {
            _total = max(1, total)
        }
    }
    
    var downloaded: UInt64 {
        get {
            return _downloaded
        }
        
        set(downloaded) {
            _downloaded = downloaded
        }
    }
    
    
    var state: DownloadState {
        get {
            return _state
        }
        
        set(state) {
            _state = state
            
            if _state == DownloadState.Successful {
                self.downloadStateIcon.tintColor = UIColor(red: 0.0, green: 150.0/255.0, blue: 30.0/255.0, alpha: 0.0)
            }
        }
    }
    
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

        let bgView = UIImageView(image: UIImage(named: "AppBg"))
        self.backgroundView = bgView
        self.activityIndicator.hidden = true
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
