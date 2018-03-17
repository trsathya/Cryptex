//
//  GeminiPastTradesVC.swift
//  CryptEx
//
//  Created by Sathyakumar Rajaraman on 3/17/18.
//  Copyright © 2018 Sathyakumar. All rights reserved.
//

import UIKit

class GeminiPastTradesVC: RefreshableTableVC {
    let service = Services.shared.gemini
    
    override func loadData(forceFetch: Bool) {
        service.getPastTrades(completion: { (_, _) in
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }, failure: { (title, message) in
            DispatchQueue.main.async {
                let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Continue", style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        })
    }
}

extension GeminiPastTradesVC: UITableViewDataSource {
    
    func currencyPairFor(section: Int) -> String {
        return service.store.pastTradesResponse.keys.sorted()[section]
    }
    
    func pastTradesAt(section: Int) -> [Gemini.PastTrade]? {
        let currencyPair = currencyPairFor(section: section)
        return service.store.pastTradesResponse[currencyPair]?.pastTrades
    }
    
    func pastTradeAt(indexPath: IndexPath) -> Gemini.PastTrade? {
        return pastTradesAt(section: indexPath.section)?[indexPath.row]
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return service.store.pastTradesResponse.count
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
            var date = df.string(from: trade.timestamp)
            df.dateStyle = DateFormatter.Style.none
            df.timeStyle = DateFormatter.Style.short
            date = date + "\n" + df.string(from: trade.timestamp)
            cell.dateLabel.text = date
            cell.quantityLabel.text = trade.amount.stringValue
            cell.rateLabel.text = "@ " + trade.price.stringValue
            let multiplier: NSDecimalNumber = trade.type == .buy ? .one : NSDecimalNumber(value: -1)
            cell.priceInUSDLabel.text = NumberFormatter.usd.string(from: trade.amount.multiplying(by: trade.price).multiplying(by: multiplier))
        }
        return cell
    }
}

class PastTradesCell: UITableViewCell {
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var quantityLabel: UILabel!
    @IBOutlet weak var rateLabel: UILabel!
    @IBOutlet weak var priceInUSDLabel: UILabel!
}
