//
//  BackgroundService.swift
//  CryptEx
//
//  Created by Sathyakumar Rajaraman on 3/17/18.
//  Copyright © 2018 Sathyakumar. All rights reserved.
//

import UIKit
import UserNotifications

class BackgroundService {
    static var shared = BackgroundService()
    
    private init() { }
    
    func resume(completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        let sharedServices = Services.shared
        sharedServices.coinMarketCap.getGlobal { (_) in
            if let string = sharedServices.coinMarketCap.store.globalMarketDataResponse.globalData?.description {
                LocalNotificationService.notify(identifier: "CoinMarketCap", title: "CoinMarketCap", message: string)
            }
            sharedServices.gemini.getBalances(completion: { _ in
                sharedServices.poloniex.getBalances(completion: { (_) in
                    sharedServices.gdax.getBalances(completion: { (_) in
                        sharedServices.binance.getBalances(completion: { (_) in
                            sharedServices.cryptopia.getBalances(completion: { (_) in
                                sharedServices.bitGrail.getBalances(completion: { (_) in
                                    sharedServices.bitfinex.getBalances { (_) in
                                        LocalNotificationService.notify(identifier: "Balance", title: nil, message: "Balance: \(NumberFormatter.usd.string(from: sharedServices.balance()) ?? "")")
                                        sharedServices.gemini.getTickers(completion: { (_) in
                                            let string = sharedServices.gemini.store.tickersDictionary.map({ (keyValue) -> String in
                                                return keyValue.key + " " + keyValue.value.price.stringValue
                                            }).joined(separator: "; ")
                                            LocalNotificationService.notify(identifier: "Gemini", title: nil, message: string)
                                            
                                            sharedServices.gdax.getTickers(completion: { (_) in
                                                let string = sharedServices.gdax.store.tickersResponse.map({ (keyValue) -> String in
                                                    return keyValue.key + " " + keyValue.value.ticker.price.stringValue
                                                }).joined(separator: "; ")
                                                LocalNotificationService.notify(identifier: "GDAX", title: nil, message: string)
                                                completionHandler(.newData)
                                            })
                                        })
                                    }
                                })
                            })
                        })
                    })
                })
            })
        }
    }
    
    func pause() {
        
    }
    
}

class LocalNotificationService {
    static func notify(identifier: String, title: String?, message: String) {
        let content = UNMutableNotificationContent()
        if let title = title {
            content.title = NSString.localizedUserNotificationString(forKey: title, arguments: nil)
        }
        content.body = NSString.localizedUserNotificationString(forKey: message, arguments: nil)
        content.sound = UNNotificationSound.default()
        // Deliver the notification in five seconds.
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger) // Schedule the notification.
        let center = UNUserNotificationCenter.current()
        center.add(request) { (error : Error?) in
            if let _ = error {
                // Handle any errors
            }
        }
    }
}
