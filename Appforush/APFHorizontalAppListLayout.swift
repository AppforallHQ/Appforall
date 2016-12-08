//
//  APFHorizontalAppListLayout.swift
//  PROJECT
//
//  Created by Sadjad Fouladi on 5/1/94.
//  Copyright (c) 1394 AP PROJECT. All rights reserved.
//

import UIKit

let ITEM_SPACING: CGFloat = (UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Phone) ? 15.0 : 20.0
let SECTION_INSET: CGFloat = 15.0
let ITEM_WIDTH: CGFloat = 80.0

class APFHorizontalAppListLayout: UICollectionViewFlowLayout {
   
    override init() {
        super.init()
        
        self.itemSize = CGSizeMake(ITEM_WIDTH, 130)
        self.scrollDirection = UICollectionViewScrollDirection.Horizontal
        self.sectionInset = UIEdgeInsetsMake(0, CGFloat(SECTION_INSET), 0, CGFloat(SECTION_INSET))
        self.minimumInteritemSpacing = 0;
        self.minimumLineSpacing = ITEM_SPACING;
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func shouldInvalidateLayoutForBoundsChange(newBounds: CGRect) -> Bool {
        return true
    }
    
    override func targetContentOffsetForProposedContentOffset(proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        let totalSize = self.collectionViewContentSize()
        let visibleSize = self.collectionView?.bounds.size
        
        var y = proposedContentOffset.y
        let k = max(floor((proposedContentOffset.x - (ITEM_SPACING + ITEM_WIDTH / 2)) / (ITEM_SPACING + ITEM_WIDTH)), -1) + 1
        
        let x = (ITEM_WIDTH + ITEM_SPACING) * k
        
        if let vs = visibleSize {
            if proposedContentOffset.x >= totalSize.width - vs.width - ITEM_SPACING {
               return CGPointMake(totalSize.width - vs.width, proposedContentOffset.y)
            }
        }
        
        return CGPointMake(x, proposedContentOffset.y)
    }
}
