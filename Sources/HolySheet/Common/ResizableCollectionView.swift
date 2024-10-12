//
//  ResizableCollectionView.swift
//  Beautisheet
//
//  Created by BAHATTIN KOC on 12.10.2024.
//

import UIKit

final class ResizableCollectionView: UICollectionView {
    override var contentSize: CGSize {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }

    override var intrinsicContentSize: CGSize { contentSize }
}
