//
//  ResizableTableView.swift
//  Beautisheet
//
//  Created by BAHATTIN KOC on 12.10.2024.
//

import UIKit

open class ResizableTableView: UITableView {
    public override var contentSize: CGSize {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }

    public override var intrinsicContentSize: CGSize { contentSize }
}
