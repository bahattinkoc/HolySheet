//
//  HolySheetVC.swift
//  conal
//
//  Created by BAHATTIN KOC on 12/10/24.
//

import UIKit

public final class HolySheetVC: UIViewController {

    // MARK: - IBOUTLET

    @IBOutlet private weak var indicatorView: UIView!

    // MARK: - PRIVATE PROPERTIES

    private var contentViewController: UIViewController
    private var parentView: UIView?
    private var dismissAction: (() -> Void)?
    private var configuration = HolySheetConfiguration()
    private var bottomPresentationController: HolySheetPresentationController? {
        presentationController as? HolySheetPresentationController
    }

    // MARK: - PUBLIC PROPERTIES

    /// Set this property as true, If you think that your content size is bigger than the screen size.
    /// If your content already has scrollable components like tableView etc. just leave it as default.
    ///
    /// The default value is `false`.
    public var needScrollableView = false

    /// Set this property to `true` if you have a content that can vertically resize according to it's content.
    /// Setting this `true` will cause your content to expand the with the `HolySheet`'s content size.
    public var hasFlexibleContent = true

    /// Sets visibility of indicator view.
    public var isIndicatorViewHidden = false

    // MARK: - OVERRIDE FUNCTIONS

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = configuration.backgroundColor
        view.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner, .layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        view.layer.cornerRadius = configuration.radius
        if #available(iOS 13.0, *) {
            view.layer.cornerCurve = .continuous
        }
        indicatorView.layer.cornerRadius = indicatorView.frame.height / 2
        if #available(iOS 13.0, *) {
            indicatorView.layer.cornerCurve = .continuous
        }
        indicatorView.isHidden = isIndicatorViewHidden
        setupContainerView()
    }

    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        dismissAction?()
    }

    public override func viewLayoutMarginsDidChange() {
        super.viewLayoutMarginsDidChange()
        guard let frame = bottomPresentationController?.currentFrame, !isBeingPresented else { return }
        view.frame = frame
    }

    // MARK: - INIT

    public init(contentVC: UIViewController,
                configuration: HolySheetConfiguration? = nil,
                data: Any? = nil) {
        contentViewController = contentVC
        if let data = data as? (() -> Void) {
            dismissAction = data
        }
        if let configuration {
            self.configuration = configuration
        }
        super.init(nibName: "HolySheetVC", bundle: Bundle.module)
        transitioningDelegate = self
        modalPresentationStyle = .custom
    }

    public required init?(coder: NSCoder) { fatalError() }

    // MARK: - PUBLIC FUNCTIONS

    @objc public func layoutBottomContentViewBeforePresenting() {
        guard let bottomPresentationController, bottomPresentationController.gestureState != .changed else { return }

        UIView.animate(withDuration: 0.3) {
            self.view.frame = bottomPresentationController.frameOfPresentedViewInContainerView
            self.view.setNeedsLayout()
            self.view.layoutIfNeeded()
        }
    }

    // MARK: - PRIVATE FUNCTIONS

    private func setupContainerView() {
        parentView = needScrollableView ? ResizableScrollView() : UIView()
        guard let parentView else { return }
        view.addSubview(parentView)
        parentView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            generateTopConstraint(for: parentView),
            parentView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            parentView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            generateBottomConstraint(for: parentView)
        ])
        setupVC(with: parentView)
        view.layoutIfNeeded()
    }

    private func setupVC(with parentView: UIView) {
        guard let contentView = contentViewController.view else { return }
        contentView.layer.cornerRadius = configuration.radius
        if #available(iOS 13.0, *) {
            contentView.layer.cornerCurve = .continuous
        }
        contentView.translatesAutoresizingMaskIntoConstraints = false
        parentView.addSubview(contentView)

        NSLayoutConstraint.activate([
            contentView.leadingAnchor.constraint(equalTo: parentView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: parentView.trailingAnchor),
            contentView.topAnchor.constraint(equalTo: parentView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: parentView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: parentView.widthAnchor)
        ])

        contentViewController.willMove(toParent: self)
        addChild(contentViewController)
        contentViewController.didMove(toParent: self)
    }

    private func generateTopConstraint(for parentView: UIView) -> NSLayoutConstraint {
        isIndicatorViewHidden
        ? parentView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16.0)
        : parentView.topAnchor.constraint(equalTo: indicatorView.bottomAnchor, constant: Constant.indicatorViewBottomAnchor)
    }

    private func generateBottomConstraint(for parentView: UIView) -> NSLayoutConstraint {
        let bottomAnchor = parentView is ResizableScrollView ? view.safeAreaLayoutGuide.bottomAnchor : view.bottomAnchor

        return hasFlexibleContent
        ? parentView.bottomAnchor.constraint(equalTo: bottomAnchor)
        : parentView.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor)
    }
}

// MARK: - UIViewControllerTransitioningDelegate

extension HolySheetVC: UIViewControllerTransitioningDelegate {
    public func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        HolySheetPresentationController(presentedViewController: presented, presenting: presenting)
    }

    public func animationController(forPresented presented: UIViewController,
                             presenting: UIViewController,
                             source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        HolySheetAnimationController(transitionStyle: .presentation)
    }

    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        HolySheetAnimationController(transitionStyle: .dismissal)
    }
}

// MARK: - CONSTANTS

private extension HolySheetVC {
    enum Constant {
        static let indicatorViewBottomAnchor = 16.0
    }
}
