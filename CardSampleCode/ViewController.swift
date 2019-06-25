//
//  ViewController.swift
//  CardSampleCode
//
//  Created by steve on 20/06/2019.
//  Copyright © 2019 BrainTools. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIGestureRecognizerDelegate {
    
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var topConstraint: NSLayoutConstraint!
    
    private var initialTranslationY: CGFloat = 0
    private var panGestureRecognizer: UIPanGestureRecognizer!
    private var tableViewPanGestureRecognizer: UIPanGestureRecognizer!
    private var tableView: UITableView!
    
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
                tableView.bounces = true
                tableView.showsVerticalScrollIndicator = true
            } else {
                tableView.bounces = false
                tableView.showsVerticalScrollIndicator = false
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(self.handlePan(_:)))
        containerView.addGestureRecognizer(panGestureRecognizer)
        panGestureRecognizer.delegate = self
        
        let listViewController = children.first! as! ListViewController
        tableView = listViewController.tableView
        listViewController.tableView.panGestureRecognizer.addTarget(self, action: #selector(self.handlePan(_:)))
    }
    
    deinit {
        containerView.gestureRecognizers?.forEach(view.removeGestureRecognizer)
        tableView.gestureRecognizers?.forEach(view.removeGestureRecognizer)
    }
    
    @objc func handlePan(_ recognizer: UIPanGestureRecognizer) {
        
        let translation = recognizer.translation(in: recognizer.view!.superview)
        
        switch recognizer {
        case tableView.panGestureRecognizer:
            if case .half = cardPosition {
                tableView.contentOffset = .zero
            }
            break
        case panGestureRecognizer:
            if tableView.contentOffset.y == 0 {
                cardPosition = .half
                
            } else if topConstraint.constant == 50 {
                cardPosition = .top
            }
            
            if case .top = cardPosition, tableView.contentOffset.y >= 0 {
                initialTranslationY = translation.y - topConstraint.constant
                return
            }
            
            switch recognizer.state {
            case .began:
                initialTranslationY = translation.y - topConstraint.constant
            case .changed:
                let y = translation.y - initialTranslationY
                if y <= 50 {
                    topConstraint.constant = 50
                    cardPosition = .top
                } else {
                    topConstraint.constant = y
                    cardPosition = .half
                    tableView.contentOffset = .zero
                }
            case .ended, .cancelled, .failed:
                let y = translation.y - initialTranslationY
                
                if y > 50 {
                    DispatchQueue.main.async {
                        self.tableView.setContentOffset(.zero, animated: false)
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
                    if y < ((UIScreen.main.bounds.height.half + 50) / 2) {
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
            let duration: TimeInterval = TimeInterval(abs(y - 50)  / 300)
            let animator = UIViewPropertyAnimator(duration: duration, dampingRatio: 0.8) { [weak self] in
                self?.topConstraint.constant = 50
                self?.view.layoutIfNeeded()
            }
            animator.startAnimation()
        case .half:
            let duration: TimeInterval = TimeInterval(abs(y - UIScreen.main.bounds.height.half) / 300)
            let animator = UIViewPropertyAnimator(duration: duration, dampingRatio: 0.8) { [weak self] in
                self?.topConstraint.constant = UIScreen.main.bounds.height.half
                self?.view.layoutIfNeeded()
            }
            animator.startAnimation()
        }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

extension CGFloat {
    var half: CGFloat {
        return self / 2.0
    }
}
