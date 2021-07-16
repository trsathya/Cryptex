//
//  BalancesVC.swift
//  CryptExUI
//
//  Created by Sathyakumar Rajaraman on 3/17/18.
//  Copyright © 2018 Sathyakumar. All rights reserved.
//

import Foundation
import UIKit

class BalancesVC: RefreshableTableVC {
    var service: BalanceServiceType!
    var dataStore: BalanceTableViewDataSource!
    
    @IBOutlet private weak var totalLabel: UILabel!
    
    override func loadData(forceFetch: Bool) {
        tableView.register(UINib(nibName: "TickerCell", bundle: nil), forCellReuseIdentifier: "TickerCell")
        updateTotalBalance()
        
        service.getBalances(completion: { (_) in
            DispatchQueue.main.async {
                self.updateTotalBalance()
                self.tableView.reloadData()
            }
        })
    }
    
    func updateTotalBalance() {
        self.totalLabel.text = NumberFormatter.usd.string(from: dataStore.getTotalBalance())
    }
}

extension BalancesVC: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataStore.balanceCount()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TickerCell", for: indexPath) as! TickerCell
        let balance = dataStore.displayableBalance(row: indexPath.row)
        cell.nameLabel.text = balance.name
        cell.priceLabel.text = balance.balanceQuantity
        cell.USDPriceLabel.text = balance.priceInUSD
        return cell
    }
}
