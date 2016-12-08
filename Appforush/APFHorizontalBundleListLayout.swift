//
//  APFHorizontalAppListLayout.swift
//  PROJECT
//
//  Created by Sadjad Fouladi on 5/1/94.
//  Copyright (c) 1394 AP PROJECT. All rights reserved.
//

import UIKit

let BUNDLE_LIST_ITEM_SPACING: CGFloat = SECTION_INSET //(UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Phone) ? 8.0 : 12.0
let BUNDLE_LIST_ITEM_WIDTH: CGFloat = 160.0

class APFHorizontalBundleListLayout: UICollectionViewFlowLayout {
   
    override init() {
        super.init()
        
        self.itemSize = CGSizeMake(BUNDLE_LIST_ITEM_WIDTH, 80)
        self.scrollDirection = UICollectionViewScrollDirection.Horizontal
        self.sectionInset = UIEdgeInsetsMake(0, CGFloat(SECTION_INSET), 0, CGFloat(SECTION_INSET))
        self.minimumInteritemSpacing = 0
        self.minimumLineSpacing = BUNDLE_LIST_ITEM_SPACING
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
        let k = max(floor((proposedContentOffset.x - (BUNDLE_LIST_ITEM_SPACING + BUNDLE_LIST_ITEM_WIDTH / 2)) / (BUNDLE_LIST_ITEM_SPACING + BUNDLE_LIST_ITEM_WIDTH)), -1) + 1
        
        let x = (BUNDLE_LIST_ITEM_WIDTH + BUNDLE_LIST_ITEM_SPACING) * k
        
        if let vs = visibleSize {
            if proposedContentOffset.x >= totalSize.width - vs.width - BUNDLE_LIST_ITEM_SPACING {
               return CGPointMake(totalSize.width - vs.width, proposedContentOffset.y)
            }
        }
        
        return CGPointMake(x, proposedContentOffset.y)
    }
}
