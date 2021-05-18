//
//  TickersVC.swift
//  CryptExUI
//
//  Created by Sathyakumar Rajaraman on 3/17/18.
//  Copyright © 2018 Sathyakumar. All rights reserved.
//

import Foundation
import UIKit

class TickersVC: RefreshableTableVC, UITableViewDataSource {
    @IBOutlet weak var toolbar: UIToolbar!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    var navigationBarHeight: CGFloat = 0.0
    
    var dataStore: TickerTableViewDataSource!
    var service: TickerServiceType!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "TickerCell", bundle: nil), forCellReuseIdentifier: "TickerCell")
        let navigationBar = self.navigationController?.navigationBar
        navigationBar?.shadowImage = UIImage()
    }
    
    override func loadData(forceFetch: Bool) {
        service.getTickers(completion: { _ in
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        })
    }
    
    @IBAction func segmentedControlValueChanged(sender: UISegmentedControl) {
        tableView.reloadData()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        guard let type = TickerViewType(rawValue: segmentedControl.selectedSegmentIndex) else { return 0 }
        return dataStore.sectionCount(viewType: type)
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let type = TickerViewType(rawValue: segmentedControl.selectedSegmentIndex) else { return "" }
        return dataStore.sectionHeaderTitle(section: section, viewType: type)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let type = TickerViewType(rawValue: segmentedControl.selectedSegmentIndex) else { return 0 }
        return dataStore.tickerCount(section: section, viewType: type)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TickerCell", for: indexPath) as! TickerCell
        guard let type = TickerViewType(rawValue: segmentedControl.selectedSegmentIndex), let displayableTicker = dataStore.displayableTicker(section: indexPath.section, row: indexPath.row, viewType: type) else { return cell }
        cell.nameLabel.text = displayableTicker.name
        cell.priceLabel.text = displayableTicker.price
        cell.USDPriceLabel.text = displayableTicker.formattedPriceInAccountingCurrency
        return cell
    }
}

