//
//  CardView.swift
//  CardSampleCode
//
//  Created by steve on 20/06/2019.
//  Copyright © 2019 BrainTools. All rights reserved.
//

import UIKit

class CardView: UIView, UIGestureRecognizerDelegate {
    
    private var topConstraint: NSLayoutConstraint!
    private var topConstraintConstant: CGFloat = 0
    
    private var parentViewController: UIViewController
    private var childViewController: ScrollViewContaining & UIViewController
    private var scrollView: UIScrollView! {
        return childViewController.scrollView
    }
    
    private var initialTranslationY: CGFloat = 0
    private var panGestureRecognizer: UIPanGestureRecognizer!
    private var tableViewPanGestureRecognizer: UIPanGestureRecognizer!
    
    private enum CardPosition {
        case top
        case half
    }
    private var cardPosition: CardPosition = .top {
        didSet {
            guard oldValue != cardPosition else {
                return
            }
            if case .top = cardPosition {
                scrollView.bounces = true
                scrollView.showsVerticalScrollIndicator = false
                scrollView.showsVerticalScrollIndicator = true
            } else {
                scrollView.bounces = false
                scrollView.showsVerticalScrollIndicator = false
            }
        }
    }
    
    init(parentViewController: UIViewController, childViewController: ScrollViewContaining & UIViewController, topConstraintConstant: CGFloat) {
        self.parentViewController = parentViewController
        self.childViewController = childViewController
        self.topConstraintConstant = topConstraintConstant
        super.init(frame: .zero)
        commonInit(frame: .zero)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func commonInit(frame: CGRect) {
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(self.handlePan(_:)))
        addGestureRecognizer(panGestureRecognizer)
        panGestureRecognizer.delegate = self
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        translatesAutoresizingMaskIntoConstraints = false
        topConstraint = topAnchor.constraint(equalTo: parentViewController.view.safeAreaLayoutGuide.topAnchor, constant: topConstraintConstant)
        let bottomConstraint = bottomAnchor.constraint(equalTo: parentViewController.view.bottomAnchor)
        bottomConstraint.priority = UILayoutPriority.defaultLow
        NSLayoutConstraint.activate([leadingAnchor.constraint(equalTo: parentViewController.view.leadingAnchor),
                                     trailingAnchor.constraint(equalTo: parentViewController.view.trailingAnchor),
                                     topConstraint,
                                     bottomConstraint])
        setupChildViewController()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        heightAnchor.constraint(equalToConstant: frame.height).isActive = true
    }

    private func setupChildViewController() {
        parentViewController.addChild(childViewController)
        childViewController.view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(childViewController.view)
        NSLayoutConstraint.activate([childViewController.view.leadingAnchor.constraint(equalTo: leadingAnchor),
                                     childViewController.view.trailingAnchor.constraint(equalTo: trailingAnchor),
                                     childViewController.view.topAnchor.constraint(equalTo: topAnchor),
                                     childViewController.view.bottomAnchor.constraint(equalTo: bottomAnchor)])
        childViewController.didMove(toParent: parentViewController)
    }

    deinit {
        gestureRecognizers?.forEach(removeGestureRecognizer)
        scrollView.gestureRecognizers?.forEach(removeGestureRecognizer)
    }

    @objc private func handlePan(_ recognizer: UIPanGestureRecognizer) {

        let translation = recognizer.translation(in: recognizer.view!.superview)

        switch recognizer {
        case scrollView.panGestureRecognizer:
            if case .half = cardPosition {
                scrollView.contentOffset = .zero
            }
            break
        case panGestureRecognizer:
            if scrollView.contentOffset.y == 0 {
                cardPosition = .half

            } else if topConstraint.constant == topConstraintConstant {
                cardPosition = .top
            }

            if case .top = cardPosition, scrollView.contentOffset.y >= 0 {
                initialTranslationY = translation.y - topConstraint.constant
                return
            }

            switch recognizer.state {
            case .began:
                initialTranslationY = translation.y - topConstraint.constant
            case .changed:
                let y = translation.y - initialTranslationY
                if y <= topConstraintConstant {
                    topConstraint.constant = topConstraintConstant
                    cardPosition = .top
                } else {
                    topConstraint.constant = y
                    cardPosition = .half
                    scrollView.contentOffset = .zero
                }
            case .ended, .cancelled, .failed:
                let y = translation.y - initialTranslationY

                if y > topConstraintConstant {
                    DispatchQueue.main.async {
                        self.scrollView.setContentOffset(.zero, animated: false)
                    }
                }

                let velocity = recognizer.velocity(in: recognizer.view!.superview)
                if abs(velocity.y) > 500 {
                    if velocity.y < 0, case .half = cardPosition {
                        cardPosition = .top
                        moveCard(y: y)
                    } else if velocity.y > 0, case .top = cardPosition {
                        cardPosition = .half
                        moveCard(y: y)
                    } else {
                        moveCard(y: y)
                    }
                } else {
                    if y < ((UIScreen.main.bounds.height.half + topConstraintConstant) / 2) {
                        cardPosition = .top
                    } else {
                        cardPosition = .half
                    }
                    moveCard(y: y)
                }

                initialTranslationY = 0
            default:
                break
            }
        default:
            break
        }
    }

    private func moveCard(y: CGFloat) {
        switch cardPosition {
        case .top:
            let duration: TimeInterval = TimeInterval(abs(y - topConstraintConstant)  / 300)
            let animator = UIViewPropertyAnimator(duration: duration, dampingRatio: 0.8) { [weak self] in
                guard let self = self else { return }
                self.topConstraint.constant = self.topConstraintConstant
                self.parentViewController.view.layoutIfNeeded()
            }
            animator.startAnimation()
        case .half:
            let duration: TimeInterval = TimeInterval(abs(y - UIScreen.main.bounds.height.half) / 300)
            let animator = UIViewPropertyAnimator(duration: duration, dampingRatio: 0.8) { [weak self] in
                guard let self = self else { return }
                self.topConstraint.constant = UIScreen.main.bounds.height.half
                self.parentViewController.view.layoutIfNeeded()
            }
            animator.startAnimation()
        }
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

protocol ScrollViewContaining {
    var scrollView: UIScrollView { get }
}

extension CGFloat {
    var half: CGFloat {
        return self / 2.0
    }
}
