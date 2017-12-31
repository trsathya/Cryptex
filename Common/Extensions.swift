//
//  Extensions.swift
//  Cryptex
//
//  Created by Sathyakumar Rajaraman on 12/31/17.
//

import Foundation

public let aMinute: TimeInterval = 60
public let twoMinutes: TimeInterval = aMinute * 2
public let fiveMinutes: TimeInterval = aMinute * 5
public let tenMinutes: TimeInterval = aMinute * 10
public let fifteenMinutes: TimeInterval = aMinute * 15
public let thirtyMinutes: TimeInterval = aMinute * 30
public let anHour: TimeInterval = aMinute * 60
public let aDay: TimeInterval = anHour * 24
public let aWeek: TimeInterval = aDay * 7
public let aMonth: TimeInterval = aDay * 30
public let aMonthAgo: TimeInterval = -1 * aMonth

public let en_US = Locale(identifier: "en-US")

public func data(_ any: Any) -> Data? {
    return try? JSONSerialization.data(withJSONObject: any, options: [])
}

public enum HttpMethod: String {
    case GET
    case POST
    case DELETE
    case PATCH
    case UPDATE
}

public enum LogLevel: UInt8 {
    case url = 0
    case requestHeaders = 1
    case response = 2
    case responseHeaders = 3
}

public enum ResponseType {
    case fetched
    case cached
    case noResponse
    case error
}

public extension HTTPURLResponse {
    public var date: Date? {
        guard let dateString = allHeaderFields["Date"] as? String else { return nil }
        let df = DateFormatter()
        df.dateFormat = "EEE, dd MMM yyyy HH:mm:ss zzz"
        return df.date(from: dateString)
    }
}

public extension NumberFormatter {
    public static var usd: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.locale = en_US
        formatter.numberStyle = .currency
        return formatter
    }
}

public extension DateFormatter {
    public static func doubleLineDateTime(date: Date) -> String {
        let df = DateFormatter()
        df.dateStyle = DateFormatter.Style.short
        df.timeStyle = DateFormatter.Style.none
        var string = df.string(from: date)
        df.dateStyle = DateFormatter.Style.none
        df.timeStyle = DateFormatter.Style.short
        string = string + "\n" + df.string(from: date)
        return string
    }
}

public extension NSDecimalNumber {
    public convenience init(any: Any?) {
        self.init(string: any as? String)
    }

    public static var thousand: NSDecimalNumber {
        return NSDecimalNumber(value: 1000)
    }
    
    public var timestampInSeconds: Int64 {
        let handler = NSDecimalNumberHandler(roundingMode: NSDecimalNumber.RoundingMode.down, scale: 0, raiseOnExactness: true, raiseOnOverflow: true, raiseOnUnderflow: true, raiseOnDivideByZero: true)
        return rounding(accordingToBehavior: handler).int64Value
    }
}

public extension NSDecimalNumberHandler {
    
    public static var round: NSDecimalNumberHandler {
        return NSDecimalNumberHandler(scale: 0)
    }
    
    public static var zeroDotEight: NSDecimalNumberHandler {
        return NSDecimalNumberHandler(scale: 8)
    }
    
    public convenience init(scale: Int16) {
        self.init(roundingMode: .down, scale: scale, raiseOnExactness: true, raiseOnOverflow: true, raiseOnUnderflow: true, raiseOnDivideByZero: true)
    }
}

public extension String {
    public func utf8Data() -> Data? {
        return data(using: .utf8)
    }
}

public extension APIType {
    
    public var mutableRequest: NSMutableURLRequest {
        let url = URL(string: host + path)!
        let mutableURLRequest = NSMutableURLRequest(url: url)
        mutableURLRequest.httpMethod = httpMethod.rawValue
        return mutableURLRequest
    }
    
    public func checkInterval(response: HTTPURLResponse?) -> Bool {
        guard let response = response, let date = response.date, Date().timeIntervalSince(date) < refetchInterval else { return false }
        return true
    }
    
    public func print(_ any: Any, content: LogLevel) {
        guard content.rawValue <= loggingEnabled.rawValue else { return }
        Swift.print(any)
    }
}

public extension NSMutableURLRequest {
    public func printHeaders() {
        if let headers = allHTTPHeaderFields, headers.count > 0 {
            print("Headers:")
            headers.forEach { key, value in
                print("    \(key): \(value)")
            }
        }
    }
}

public extension Dictionary where Key: ExpressibleByStringLiteral, Value: ExpressibleByStringLiteral {
    var queryString: String {
        var postDataString = ""
        forEach { tuple in
            if postDataString.count != 0 {
                postDataString += "&"
            }
            postDataString += "\(tuple.key)=\(tuple.value)"
        }
        return postDataString
    }
}

