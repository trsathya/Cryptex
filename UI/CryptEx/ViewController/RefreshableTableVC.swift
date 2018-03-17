//
//  RefreshableTableVC.swift
//  CryptEx
//
//  Created by Sathyakumar Rajaraman on 3/17/18.
//  Copyright © 2018 Sathyakumar. All rights reserved.
//

import UIKit

class RefreshableTableVC: UIViewController {
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        let rc = UIRefreshControl()
        rc.addTarget(self, action: #selector(fetchData(refreshControl:)), for: .valueChanged)
        tableView.refreshControl = rc
        loadData(forceFetch: false)
    }
    
    @objc func fetchData(refreshControl: UIRefreshControl?) {
        refreshControl?.endRefreshing()
        loadData(forceFetch: true)
    }
    
    func loadData(forceFetch: Bool) {
        fatalError()
    }
}
