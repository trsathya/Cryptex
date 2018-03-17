//
//  PoloniexTradeHistoryVC.swift
//  CryptEx
//
//  Created by Sathyakumar Rajaraman on 3/17/18.
//  Copyright © 2018 Sathyakumar. All rights reserved.
//

import UIKit

class PoloniexTradeHistoryVC: RefreshableTableVC {
    let service = Services.shared.poloniex
    override func loadData(forceFetch: Bool) {
        
        let now = Date()
        let start = Date(timeInterval: .aMonthAgo, since: now) // expose a date picker for start date
        
        service.returnTradeHistory(start: start, end: now, completion: { (_) in
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }, captcha: { (captchaString) in
            
        })
    }
}

extension PoloniexTradeHistoryVC: UITableViewDataSource {
    func currencyPairFor(section: Int) -> String {
        return service.store.pastTradesResponse.pastTrades.keys.sorted()[section]
    }
    
    func pastTradesAt(section: Int) -> [Poloniex.PastTrade]? {
        return service.store.pastTradesResponse.pastTrades[currencyPairFor(section: section)]
    }
    
    func pastTradeAt(indexPath: IndexPath) -> Poloniex.PastTrade? {
        return pastTradesAt(section: indexPath.section)?[indexPath.row]
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return service.store.pastTradesResponse.pastTrades.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let count = pastTradesAt(section: section)?.count, count > 0 else { return nil }
        return currencyPairFor(section: section)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pastTradesAt(section: section)?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PastTradesCell", for: indexPath) as! PastTradesCell
        
        if let trade = pastTradeAt(indexPath: indexPath) {
            let df = DateFormatter()
            df.dateStyle = DateFormatter.Style.short
            df.timeStyle = DateFormatter.Style.none
            var date = df.string(from: trade.date)
            df.dateStyle = DateFormatter.Style.none
            df.timeStyle = DateFormatter.Style.short
            date = date + "\n" + df.string(from: trade.date)
            cell.dateLabel.text = date
            cell.quantityLabel.text = trade.amount.stringValue
            cell.rateLabel.text = "@ " + trade.rate.stringValue
            let multiplier: NSDecimalNumber = trade.type == .buy ? .one : NSDecimalNumber(value: -1)
            cell.priceInUSDLabel.text = trade.amount.multiplying(by: trade.rate).multiplying(by: multiplier).rounding(accordingToBehavior: NSDecimalNumberHandler.zeroDotEight).stringValue
        }
        return cell
    }
}
