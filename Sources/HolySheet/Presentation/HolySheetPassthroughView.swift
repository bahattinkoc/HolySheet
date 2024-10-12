//
//  HolySheetPassthroughView.swift
//  conal
//
//  Created by BAHATTIN KOC on 12/10/24.
//

import UIKit

final class HolySheetPassthroughView: UIView {
    var view: UIView?

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        var view = super.hitTest(point, with: event)
        if view == self {
            view = self.view?.hitTest(point, with: event)
        }
        return view
    }
}
