//
//  ViewController.swift
//  GeminiApp
//
//  Created by Sathyakumar Rajaraman on 3/17/18.
//  Copyright © 2018 Sathyakumar. All rights reserved.
//

import UIKit

class ExchangeVC: RefreshableTableVC {

    let exchangeNames: [String] = ["All", "Gemini", "Poloniex", "GDAX", "Binance", "Cryptopia", "BitGrail", "CoinExchange", "Bitfinex", "Koinex", "Kraken"]
    let exchangeOptions: [[String]] = [
        ["Balances"],
        ["Tickers", "Balances"
            ,"PastTrades"
        ],
        ["Tickers", "Balances"
            ,"TradeHistory"
            ,"DepositsWithdrawals"
        ],
        ["Tickers", "Balances"],
        ["Tickers", "Balances"],
        ["Tickers", "Balances"],
        ["Tickers", "Balances"],
        ["Tickers"],
        ["Tickers"],
        ["Tickers"],
        ["Tickers"]
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "TickerCell", bundle: nil), forCellReuseIdentifier: "TickerCell")
    }
    
    override func loadData(forceFetch: Bool) {
        Services.shared.fetchAllBalances(completion: {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }, failure: nil, captcha: { captchaString in
            print("Error while loading data")
        })
    }
}

extension ExchangeVC: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return exchangeNames.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return exchangeOptions[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TickerCell", for: indexPath) as! TickerCell
        cell.nameLabel.text = exchangeNames[indexPath.section] + " " + exchangeOptions[indexPath.section][indexPath.row]
        switch (indexPath.section, indexPath.row) {
        case (0, 0):
            cell.USDPriceLabel.text = NumberFormatter.usd.string(from: Services.shared.balance())
        case (1, 1):
            cell.USDPriceLabel.text = NumberFormatter.usd.string(from: Services.shared.gemini.store.getTotalBalance())
        case (2, 1):
            cell.USDPriceLabel.text = NumberFormatter.usd.string(from: Services.shared.poloniex.store.getTotalBalance())
        case (3, 1):
            cell.USDPriceLabel.text = NumberFormatter.usd.string(from: Services.shared.gdax.store.getTotalBalance())
        case (4, 1):
            cell.USDPriceLabel.text = NumberFormatter.usd.string(from: Services.shared.binance.store.getTotalBalance())
        case (5, 1):
            cell.USDPriceLabel.text = NumberFormatter.usd.string(from: Services.shared.cryptopia.store.getTotalBalance())
        case (6, 1):
            if let btcusdPrice = Services.shared.gemini.store.tickersDictionary["BTCUSD"]?.price {
                let xrbusdPrice = btcusdPrice.multiplying(by: Services.shared.bitGrail.store.getTotalBalance())
                cell.USDPriceLabel.text = NumberFormatter.usd.string(from: xrbusdPrice)
            } else {
                cell.USDPriceLabel.text = nil
            }
        default:
            cell.USDPriceLabel.text = nil
        }
        cell.priceLabel.text = nil
        return cell
    }
}

extension ExchangeVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 0 {
            performSegue(withIdentifier: "show" + exchangeNames[indexPath.section] + exchangeOptions[indexPath.section][indexPath.row], sender: self)
        } else {
            if indexPath.row == 0 {
                if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TickersVC") as? TickersVC {
                    switch (indexPath.section) {
                    case 1:
                        vc.dataStore = Services.shared.gemini.store
                        vc.service = Services.shared.gemini
                    case 2:
                        vc.dataStore = Services.shared.poloniex.store
                        vc.service = Services.shared.poloniex
                    case 3:
                        vc.dataStore = Services.shared.gdax.store
                        vc.service = Services.shared.gdax
                    case 4:
                        vc.dataStore = Services.shared.binance.store
                        vc.service = Services.shared.binance
                    case 5:
                        vc.dataStore = Services.shared.cryptopia.store
                        vc.service = Services.shared.cryptopia
                    case 6:
                        vc.dataStore = Services.shared.bitGrail.store
                        vc.service = Services.shared.bitGrail
                    case 7:
                        vc.dataStore = Services.shared.coinExchange.store
                        vc.service = Services.shared.coinExchange
                    case 8:
                        vc.dataStore = Services.shared.bitfinex.store
                        vc.service = Services.shared.bitfinex
                    case 9:
                        vc.dataStore = Services.shared.koinex.store
                        vc.service = Services.shared.koinex
                    case 10:
                        vc.dataStore = Services.shared.kraken.store
                        vc.service = Services.shared.kraken
                    default: break
                    }
                    vc.title = exchangeNames[indexPath.section]
                    navigationController?.pushViewController(vc, animated: true)
                }
            } else if indexPath.row == 1 {
                if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "BalancesVC") as? BalancesVC {
                    switch (indexPath.section) {
                    case 1:
                        vc.dataStore = Services.shared.gemini.store
                        vc.service = Services.shared.gemini
                    case 2:
                        vc.dataStore = Services.shared.poloniex.store
                        vc.service = Services.shared.poloniex
                    case 3:
                        vc.dataStore = Services.shared.gdax.store
                        vc.service = Services.shared.gdax
                    case 4:
                        vc.dataStore = Services.shared.binance.store
                        vc.service = Services.shared.binance
                    case 5:
                        vc.dataStore = Services.shared.cryptopia.store
                        vc.service = Services.shared.cryptopia
                    case 6:
                        vc.dataStore = Services.shared.bitGrail.store
                        vc.service = Services.shared.bitGrail
                    case 7:
                        vc.dataStore = Services.shared.coinExchange.store
                        vc.service = Services.shared.coinExchange
                    case 8:
                        vc.dataStore = Services.shared.bitfinex.store
                        vc.service = Services.shared.bitfinex
                    default: break
                    }
                    navigationController?.pushViewController(vc, animated: true)
                }
            }
        }
    }
}
