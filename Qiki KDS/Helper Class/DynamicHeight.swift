//
//  DynamicHeight.swift
//  Qiki Cusine
//
//  Created by Nirmit Dagly on 9/9/2022.
//

import Foundation
import UIKit

class DynamicHeightCollectionView: UICollectionView {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if bounds.size != intrinsicContentSize {
            self.invalidateIntrinsicContentSize()
        }
    }

    override var intrinsicContentSize: CGSize {
        return collectionViewLayout.collectionViewContentSize
    }
}
