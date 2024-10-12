//
//  HolySheetPresentationController.swift
//  conal
//
//  Created by BAHATTIN KOC on 12/10/24.
//

import UIKit

final class HolySheetPresentationController: UIPresentationController {

    // MARK: - PROPERTIES
    var passesTouchesToPresentingView = false
    var detend: [HolySheetDetend] = [.dynamic]
    var isCollapsable: Bool = true
    var currentFrame: CGRect = .zero

    // MARK: - PRIVATE PROPERTIES
    private var dimView = UIView()
    private var panGesture: UIPanGestureRecognizer?
    private var passthroughView: HolySheetPassthroughView?
    private var contentSize: CGSize = .zero
    private var stickyPoints: [CGFloat] = []
    private var translationY: CGFloat = .zero

    // MARK: - COMPUTED PROPERTIES
    private var containerHeight: CGFloat {
        guard let containerView else { return .zero }
        return containerView.bounds.height
    }

    private var maxHeight: CGFloat {
        guard let containerView else { return .zero }
        return containerHeight - containerView.safeAreaInsets.top
    }

    private var minY: CGFloat {
        guard let containerView else { return .zero }
        return containerView.bounds.inset(by: containerView.safeAreaInsets).minY
    }

    var gestureState: UIGestureRecognizer.State? {
        panGesture?.state
    }

    // MARK: - OVERRIDE FUNCTIONS

    override func presentationTransitionWillBegin() {
        super.presentationTransitionWillBegin()

        setupPanGesture()
        animateDimViewPresentation()

        if passesTouchesToPresentingView {
            setupPassthroughView()
        } else {
            setupDimView()
            setupTapGesture()
        }
    }

    override func dismissalTransitionWillBegin() {
        super.dismissalTransitionWillBegin()
        animateDimViewDismissal()
    }

    override func containerViewWillLayoutSubviews() {
        super.containerViewWillLayoutSubviews()

        dimView.frame = containerView?.bounds ?? .zero

        if panGesture?.state != .changed {
            presentedView?.frame = currentFrame
        }
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate { [weak self] _ in
            guard let self else { return }
            self.presentedView?.frame = self.frameOfPresentedViewInContainerView
        }
    }

    override var frameOfPresentedViewInContainerView: CGRect {
        guard let presentedView, let containerView else { return .zero }

        let width = containerView.bounds
            .inset(by: containerView.safeAreaInsets)
            .insetBy(dx: 8.0, dy: 8.0)
            .width

        contentSize = presentedView.systemLayoutSizeFitting(
            CGSize(width: width, height: .zero),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .defaultLow
        )

        currentFrame = getInitialFrame(width: width, contentSize: contentSize)
        return currentFrame
    }

    // MARK: - PRIVATE FUNCTIONS

    private func getInitialFrame(width: CGFloat, contentSize: CGSize) -> CGRect {
        guard let containerView else { return .zero }

        calculateStickyPoints()
        let firstStickyPoint = stickyPoints.max() ?? .zero
        let initialHeight = containerHeight - firstStickyPoint
        let minHeight = max(initialHeight, contentSize.height)
        let presentedHeight: CGFloat = min(minHeight, maxHeight) - 8.0

        return CGRect(
            x: (containerView.bounds.width - width) / 2,
            y: max(minY, firstStickyPoint),
            width: width,
            height: presentedHeight
        )
    }

    private func setupDimView() {
        dimView.backgroundColor = .black.withAlphaComponent(Constant.dimViewAlpha)
        dimView.frame = containerView?.bounds ?? .zero
        containerView?.insertSubview(dimView, at: 0)
    }

    private func animateDimViewPresentation() {
        dimView.alpha = 0
        animate { [weak self] in
            guard let self else { return }
            self.dimView.alpha = 1
        }
    }

    private func animateDimViewDismissal() {
        animate { [weak self] in
            guard let self else { return }
            self.dimView.alpha = 0
        }
    }

    private func animate(animation: @escaping () -> Void) {
        presentedViewController.transitionCoordinator?.animate { _ in
            animation()
        }
    }

    private func setupPassthroughView() {
        guard let containerView else { return }
        let passthroughView = self.passthroughView ?? HolySheetPassthroughView()
        passthroughView.frame = containerView.bounds
        containerView.insertSubview(passthroughView, at: 0)
        passthroughView.view = presentingViewController.view
        self.passthroughView = passthroughView
    }

    private func calculateStickyPoints() {
        var heightArray: [CGFloat] = []
        detend.forEach({ detend in
            switch detend {
            case .dynamic:
                let height = containerHeight - contentSize.height > 0 ? contentSize.height : currentFrame.size.height
                heightArray.append(height)
            case .medium:
                heightArray.append(containerHeight / 2)
            case .custom(let height):
                heightArray.append(height)
            }
        })
        stickyPoints = heightArray.map({ containerHeight - $0 }).sorted()
    }

    // MARK: - TAP GESTURE

    private func setupTapGesture() {
        guard let containerView else { return }

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        tapGesture.cancelsTouchesInView = false
        tapGesture.delegate = self
        containerView.addGestureRecognizer(tapGesture)
    }

    @objc private func handleTap() {
        presentedViewController.dismiss(animated: true)
    }

    // MARK: - PAN GESTURE

    private func setupPanGesture() {
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture))
        guard let presentedView, let panGesture else { return }

        presentedView.isUserInteractionEnabled = true
        presentedView.addGestureRecognizer(panGesture)
    }

    @objc private func handlePanGesture(_ gestureRecognizer: UIPanGestureRecognizer) {
        guard let presentedView else { return}

        let translationY = gestureRecognizer.translation(in: presentedView.superview).y
        let velocity = gestureRecognizer.velocity(in: presentedView.superview).y

        switch gestureRecognizer.state {
        case .changed:
            handleDrag(translationY: translationY)
        case .ended:
            isCollapsable && shouldDismissOnGestureEnd(translation: translationY, velocity: velocity) ?
            presentedViewController.dismiss(animated: true) : resetPresentedViewToNearestFrame()
        default:
            return
        }
    }

    private func handleDrag(translationY: CGFloat) {
        guard let presentedView else { return }
        let maxY = presentedView.frame.origin.y
        let stickyY = stickyPoints.min() ?? .zero
        if translationY < 0 && maxY < stickyY {
            let newTranslationY = self.translationY + (translationY / Constant.translationYDivider)
            drivePresentedView(with: newTranslationY)
        } else {
            self.translationY = translationY
            drivePresentedView(with: translationY)
        }
    }

    private func drivePresentedView(with translationY: CGFloat) {
        let initialFrame = currentFrame
        let newY = initialFrame.origin.y + translationY
        let newHeight = max((initialFrame.size.height - translationY), contentSize.height)
        let minHeight = min(newHeight, maxHeight)

        presentedView?.frame = CGRect(
            x: initialFrame.origin.x,
            y: max(minY, newY),
            width: initialFrame.width,
            height: minHeight
        )
    }

    private func shouldDismissOnGestureEnd(translation: CGFloat, velocity: CGFloat) -> Bool {
        let initialFrame = currentFrame
        let finalY = initialFrame.origin.y + translation + velocity
        let finalHeight = containerHeight - finalY

        let thresholdHeight = (containerHeight - (stickyPoints.max() ?? .zero)) / 2
        return finalHeight < thresholdHeight
    }

    private func resetPresentedViewToNearestFrame() {
        guard let draggedFrame = presentedView?.frame else { return }
        UIView.animate(
            withDuration: HolySheetAnimationController.Constant.animationDuration,
            delay: 0,
            options: .allowUserInteraction) {
                let draggedY = draggedFrame.origin.y
                guard let nearestY = self.stickyPoints.nearest(to: draggedY) else { return }
                self.updateFrame(to: nearestY)
            }
    }

    private func updateFrame(to nearestY: CGFloat) {
        let newHeight = max((currentFrame.height - translationY), contentSize.height)
        let minHeight = min(newHeight, maxHeight)

        self.presentedView?.frame =  CGRect(
            x: currentFrame.origin.x,
            y: max(minY, nearestY),
            width: currentFrame.size.width,
            height: minHeight
        )
        currentFrame = presentedView?.frame ?? .zero
    }
}

// MARK: - UIGestureRecognizerDelegate

extension HolySheetPresentationController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard gestureRecognizer is UITapGestureRecognizer else { return true }

        let location = gestureRecognizer.location(in: containerView)
        let tappedAtPresentedView = presentedView?.frame.contains(location) ?? false
        return !tappedAtPresentedView
    }
}

// MARK: - CONSTANTS

private extension HolySheetPresentationController {
    enum Constant {
        static let dimViewAlpha = 0.35
        static let translationYDivider = 10.0
    }
}
