//
//  ResizableViewController.swift
//  Beautisheet
//
//  Created by BAHATTIN KOC on 12/10/24.
//

import UIKit

class ResizableViewController: UIViewController {
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        UIView.animate(withDuration: HolySheetAnimationController.Constant.animationDuration) {
            self.view.layoutIfNeeded()
        }
        parent?
            .performSelector(
                onMainThread: #selector(
                    HolySheetVC.layoutBottomContentViewBeforePresenting
                ),
                with: nil,
                waitUntilDone: false
            )
    }
}
