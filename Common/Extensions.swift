//
//  Extensions.swift
//  Cryptex
//
//  Created by Sathyakumar Rajaraman on 12/31/17.
//

import Foundation

public extension Int {
    public static let thousand = 1_000
    public static let million = 1_000_000
    public static let billion = 1_000_000
    public static let trillion = 1_000_000_000
}


public extension Locale {
    static let enUS = Locale(identifier: "en-US")
    static let enIN = Locale(identifier: "en-IN")
}

public extension TimeInterval {
    static let aMinute: TimeInterval = 60
    static let twoMinutes: TimeInterval = aMinute * 2
    static let fiveMinutes: TimeInterval = aMinute * 5
    static let tenMinutes: TimeInterval = aMinute * 10
    static let fifteenMinutes: TimeInterval = aMinute * 15
    static let thirtyMinutes: TimeInterval = aMinute * 30
    static let anHour: TimeInterval = aMinute * 60
    static let aDay: TimeInterval = anHour * 24
    static let aWeek: TimeInterval = aDay * 7
    static let aMonth: TimeInterval = aDay * 30
    static let aMonthAgo: TimeInterval = -1 * aMonth
}

public extension HTTPURLResponse {
    var date: Date? {
        guard let dateString = allHeaderFields["Date"] as? String else { return nil }
        return DateFormatter.httpHeader.date(from: dateString)
    }
}

public extension NumberFormatter {
    static var usd: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.locale = .enUS
        formatter.numberStyle = .currency
        return formatter
    }
    
    static var inr: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.locale = .enIN
        formatter.numberStyle = .currency
        return formatter
    }
}

public extension DateFormatter {
    static func doubleLineDateTime(date: Date) -> String {
        let df = DateFormatter()
        df.dateStyle = DateFormatter.Style.short
        df.timeStyle = DateFormatter.Style.none
        var string = df.string(from: date)
        df.dateStyle = DateFormatter.Style.none
        df.timeStyle = DateFormatter.Style.short
        string = string + "\n" + df.string(from: date)
        return string
    }
    
    static var httpHeader: DateFormatter {
        let df = DateFormatter()
        df.dateFormat = "EEE, dd MMM yyyy HH:mm:ss zzz"
        return df
    }
}

public extension NSDecimalNumber {
    convenience init(_ any: Any?) {
        if let string = any as? String {
            self.init(string: string)
        } else if let number = (any as? NSNumber)?.decimalValue {
            self.init(decimal: number)
        } else {
            self.init(value: 0)
        }
    }

    static var thousand: NSDecimalNumber {
        return NSDecimalNumber(value: Int.thousand)
    }
    
    static var million: NSDecimalNumber {
        return NSDecimalNumber(value: Int.million)
    }
    
    static var billion: NSDecimalNumber {
        return NSDecimalNumber(value: Int.billion)
    }
    
    static var trillion: NSDecimalNumber {
        return NSDecimalNumber(value: Int.trillion)
    }
    
    var timestampInSeconds: Int64 {
        let handler = NSDecimalNumberHandler(roundingMode: NSDecimalNumber.RoundingMode.down, scale: 0, raiseOnExactness: true, raiseOnOverflow: true, raiseOnUnderflow: true, raiseOnDivideByZero: true)
        return rounding(accordingToBehavior: handler).int64Value
    }
    
    var shortFormatted: String {
        var temp = self
        var suffix = ""
        if intValue >= Int.trillion {
            temp = temp.dividing(by: .trillion)
            suffix = "T"
        } else if intValue >= Int.billion {
            temp = temp.dividing(by: .billion)
            suffix = "B"
        }  else if intValue >= Int.million {
            temp = temp.dividing(by: .million)
            suffix = "M"
        } else if intValue >= Int.thousand {
            temp = temp.dividing(by: .thousand)
            suffix = "K"
        }
        let num = NumberFormatter.usd.string(from: temp) ?? ""
        return num + suffix
    }
    
    var usdFormatted: String? {
        return NumberFormatter.usd.string(from: self)
    }
}

public extension NSDecimalNumberHandler {
    
    static var round: NSDecimalNumberHandler {
        return NSDecimalNumberHandler(scale: 0)
    }
    
    static var zeroDotEight: NSDecimalNumberHandler {
        return NSDecimalNumberHandler(scale: 8)
    }
    
    convenience init(scale: Int16) {
        self.init(roundingMode: .down, scale: scale, raiseOnExactness: true, raiseOnOverflow: true, raiseOnUnderflow: true, raiseOnDivideByZero: true)
    }
}

public extension String {
    func utf8Data() -> Data? {
        return data(using: .utf8)
    }
}

public extension NSMutableURLRequest {
    func printHeaders() {
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

extension Data {
    var string: String? {
        return String(data: self, encoding: .utf8)
    }
}

public extension Dictionary {
    var data: Data? {
        return try? JSONSerialization.data(withJSONObject: self, options: [])
    }
}

extension HTTPURLResponse {
    open override var description: String {
        return "\(statusCode) \(self.url?.absoluteString ?? "")"
    }
}
