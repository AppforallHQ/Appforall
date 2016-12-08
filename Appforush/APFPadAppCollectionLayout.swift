//
//  APFPadAppCollectionLayout.swift
//  PROJECT
//
//  Created by Sadjad Fouladi on 22/1/94.
//  Copyright (c) 1394 AP PROJECT. All rights reserved.
//

import UIKit

class APFPadAppCollectionLayout: UICollectionViewFlowLayout {
    init(isCategory: Bool) {
        super.init()
        
        var height = PAD_CELL_ITEM_HEIGHT
        
        if isCategory {
            height = PAD_CELL_CAT_ITEM_HEIGHT
        }
        
        self.itemSize = CGSizeMake(PAD_CELL_ITEM_WIDTH, height)
        self.scrollDirection = UICollectionViewScrollDirection.Vertical
        self.sectionInset = UIEdgeInsetsMake(26.0, 26.0, 26.0, 26.0)
        self.minimumInteritemSpacing = PAD_CELL_ITEM_SPACING;
        self.minimumLineSpacing = 12.0;
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func shouldInvalidateLayoutForBoundsChange(newBounds: CGRect) -> Bool {
        return true
    }
}
