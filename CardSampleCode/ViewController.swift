//
//  ViewController.swift
//  CardSampleCode
//
//  Created by steve on 25/06/2019.
//  Copyright © 2019 BrainTools. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        if let listViewController = storyboard.instantiateViewController(withIdentifier: "ListViewController") as? ListViewController {
            let cardView = CardView(parentViewController: self, childViewController: listViewController, topConstraintConstant: 50)
            view.addSubview(cardView)
        }
    }
}
