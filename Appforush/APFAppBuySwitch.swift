//
//  APFAppBuySwitch.swift
//  PROJECT
//
//  Created by Sadjad Fouladi on 20/3/94.
//  Copyright (c) 1394 AP PROJECT. All rights reserved.
//

import UIKit

enum APFAppState {
    case PROJECT
    case AppBuy
}

protocol APFAppBuySwitchDelegate {
    func appBuyStateChanged(to: APFAppState, sender: APFAppBuySwitch);
}

class APFAppBuySwitch: UIControl {

    var appState: APFAppState = .PROJECT
    var delegate: APFAppBuySwitchDelegate! = nil
    
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
