//
//  AllBalancesVC.swift
//  CryptEx
//
//  Created by Sathyakumar Rajaraman on 3/17/18.
//  Copyright © 2018 Sathyakumar. All rights reserved.
//

import UIKit

class AllBalancesVC: RefreshableTableVC {
    
    var geminiService: Gemini.Service = Services.shared.gemini
    var poloniexService: Poloniex.Service = Services.shared.poloniex
    var gdaxService: GDAX.Service = Services.shared.gdax
    
    @IBOutlet private weak var totalLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "TickerCell", bundle: nil), forCellReuseIdentifier: "TickerCell")
    }
    
    override func loadData(forceFetch: Bool) {
        
        Services.shared.fetchAllBalances(completion: { 
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.updateTotalBalance()
            }
        }, failure: { title, message in
            DispatchQueue.main.async {
                let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Continue", style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }, captcha: { captchaString in
            
        })
    }
    
    func updateTotalBalance() {
        totalLabel.text = NumberFormatter.usd.string(from: Services.shared.balance())
    }
    
    func exchangeNamesFor(indexPath: IndexPath) -> String {
        switch indexPath.row {
        case 0:
            return "Gemini"
        case 1:
            return "Poloniex"
        case 2:
            return "GDAX"
        default:
            return ""
        }
    }
}

extension AllBalancesVC: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "TickerCell", for: indexPath) as! TickerCell
        
        cell.nameLabel.text = exchangeNamesFor(indexPath: indexPath)
        cell.priceLabel.text = nil
        cell.accessoryType = .disclosureIndicator
        
        switch indexPath.row {
        case 0:
            cell.USDPriceLabel.text = NumberFormatter.usd.string(from: Services.shared.gemini.store.getTotalBalance())
        case 1:
            cell.USDPriceLabel.text = NumberFormatter.usd.string(from: Services.shared.poloniex.store.getTotalBalance())
        case 2:
            cell.USDPriceLabel.text = NumberFormatter.usd.string(from: Services.shared.gdax.store.getTotalBalance())
        case 3:
            cell.USDPriceLabel.text = NumberFormatter.usd.string(from: Services.shared.binance.store.getTotalBalance())
        case 4:
            cell.USDPriceLabel.text = NumberFormatter.usd.string(from: Services.shared.cryptopia.store.getTotalBalance())
        case 5:
            if let btcusdPrice = Services.shared.gemini.store.tickersDictionary["BTCUSD"]?.price {
                let xrbusdPrice = btcusdPrice.multiplying(by: Services.shared.bitGrail.store.getTotalBalance())
                cell.USDPriceLabel.text = NumberFormatter.usd.string(from: xrbusdPrice)
            } else {
                cell.USDPriceLabel.text = nil
            }
        default:
            break
        }
        return cell
    }
}

extension AllBalancesVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "expand" + exchangeNamesFor(indexPath: indexPath) + "Balances", sender: self)
    }
}
