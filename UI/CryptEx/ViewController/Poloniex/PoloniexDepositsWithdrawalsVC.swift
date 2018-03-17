//
//  PoloniexDepositsWithdrawalsVC.swift
//  CryptEx
//
//  Created by Sathyakumar Rajaraman on 3/17/18.
//  Copyright © 2018 Sathyakumar. All rights reserved.
//

import UIKit

class PoloniexDepositsWithdrawalsVC: RefreshableTableVC {
    let service = Services.shared.poloniex
    
    override func loadData(forceFetch: Bool) {
        
        let now = Date()
        let start = Date(timeInterval: .aMonthAgo, since: now)
        
        service.returnDepositsWithdrawals(start: start, end: now, completion: { _ in
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        })
    }
}

extension PoloniexDepositsWithdrawalsVC: UITableViewDataSource {
    
    var deposits: [Poloniex.Deposit] {
        return service.store.depositsWithdrawalsResponse.deposits
    }
    
    var withdrawals: [Poloniex.Withdrawal] {
        return service.store.depositsWithdrawalsResponse.withdrawals
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return deposits.count > 0 ? "Deposits" : nil
        case 1:
            return withdrawals.count > 0 ? "Withdrawals" : nil
        default:
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return deposits.count
        case 1:
            return withdrawals.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PastTradesCell", for: indexPath) as! PastTradesCell
        cell.quantityLabel.text = nil
        cell.rateLabel.text = nil
        switch indexPath.section {
        case 0:
            let deposit = deposits[indexPath.row]
            cell.dateLabel.text = DateFormatter.doubleLineDateTime(date: deposit.timestamp)
            cell.priceInUSDLabel.text = deposit.amount.stringValue + " " + deposit.currency.code
        case 1:
            let withdrawal = withdrawals[indexPath.row]
            cell.dateLabel.text = DateFormatter.doubleLineDateTime(date: withdrawal.timestamp)
            cell.priceInUSDLabel.text = withdrawal.amount.stringValue + " " + withdrawal.currency.code
        default:
            break
        }
        return cell
    }
    
    
}
