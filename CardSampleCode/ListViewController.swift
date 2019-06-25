//
//  ListViewController.swift
//  CardSampleCode
//
//  Created by steve on 20/06/2019.
//  Copyright © 2019 BrainTools. All rights reserved.
//

import UIKit

class ListViewController: UIViewController, UITableViewDataSource, ScrollViewContaining {
    
    @IBOutlet private weak var tableView: UITableView!
    
    var scrollView: UIScrollView {
        return tableView
    }
    
    private var strings = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l"]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return strings.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = strings[indexPath.row]
        return cell
    }
    
}
