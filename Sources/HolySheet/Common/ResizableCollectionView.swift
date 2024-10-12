//
//  ResizableCollectionView.swift
//  Beautisheet
//
//  Created by BAHATTIN KOC on 12.10.2024.
//

import UIKit

open class ResizableCollectionView: UICollectionView {
    public override var contentSize: CGSize {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }

    public override var intrinsicContentSize: CGSize { contentSize }
}
