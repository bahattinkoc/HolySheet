//
//  HolySheetAnimationController.swift
//  conal
//
//  Created by BAHATTIN KOC on 12/10/24.
//

import UIKit

final class HolySheetAnimationController: NSObject, UIViewControllerAnimatedTransitioning {

    enum TransitionStyle {
        case presentation, dismissal
    }

    // MARK: - PRIVATE PROPERTIES

    private let transitionStyle: TransitionStyle

    // MARK: - INIT

    required init(transitionStyle: TransitionStyle) {
        self.transitionStyle = transitionStyle
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        Constant.animationDuration
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        transitionStyle == .presentation ? animatePresentation(transitionContext: transitionContext)
        : animateDismissal(transitionContext: transitionContext)
    }

    // MARK: - PRIVATE FUNCTIONS

    private func animatePresentation(transitionContext: UIViewControllerContextTransitioning) {
        guard let toVC = transitionContext.viewController(forKey: .to) as? HolySheetVC else { return }

        let bottomView: UIView = toVC.view
        bottomView.frame = transitionContext.finalFrame(for: toVC)
        bottomView.transform = .init(translationX: 0, y: bottomView.frame.height)
        transitionContext.containerView.addSubview(bottomView)
        toVC.layoutBottomContentViewBeforePresenting()

        animate(transitionContext: transitionContext) {
            bottomView.transform = .identity
        }
    }

    private func animateDismissal(transitionContext: UIViewControllerContextTransitioning) {
        guard let fromVC = transitionContext.viewController(forKey: .from) else { return }
        let bottomView: UIView = fromVC.view

        animate(transitionContext: transitionContext) {
            bottomView.transform = .init(translationX: 0, y: bottomView.frame.height)
        }
    }

    private func animate(transitionContext: UIViewControllerContextTransitioning,
                         animations: @escaping () -> Void) {
        UIView.animate(
            withDuration: Constant.animationDuration,
            delay: 0,
            usingSpringWithDamping: 1,
            initialSpringVelocity: Constant.initialSpringVelocity,
            options: [.allowUserInteraction],
            animations: {
                animations()
            },
            completion: { didComplete in
                transitionContext.completeTransition(didComplete)
            }
        )
    }
}

// MARK: - CONSTANTS

extension HolySheetAnimationController {
    enum Constant {
        static let initialSpringVelocity = 0.5
        static let animationDuration = 0.3
    }
}
