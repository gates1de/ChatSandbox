//
//  Date.swift
//  ChatSandbox
//
//  Created by Yu Kadowaki on 2018/12/14.
//

import Foundation

enum DateFormatType: String {
    case iso8601                 = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
    case yearToDateNoSeparator   = "yyyyMMdd"
    case yearToMinuteNoSeparator = "yyyyMMddHHmm"
    case yearToDate              = "yyyy/MM/dd"
    case yearToDateWithDot       = "yyyy.MM.dd"
    case yearToDateJapanese      = "yyyy年MM月dd日"
    case yearToDayOfWeekJapanese = "yyyy年MM月dd日(E)"
    case yearToMonthJapanese     = "yyyy年MM月"
    case yearToMinute            = "yyyy/MM/dd HH:mm"
    case monthToMinute           = "MM/dd HH:mm"
    case monthToDate             = "MM/dd"
    case monthToDateWithSpace    = "MM / dd"
    case monthToYear             = "MM/dd/yyyy"
    case hourToMinute            = "HH:mm"
}

extension Date {

    // MARK: - Internal properties

    var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = .current
        calendar.locale   = Locale(identifier: "en_US_POSIX")
        return calendar
    }

    var dateFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.locale    = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeStyle = .short
        dateFormatter.timeZone  = .current
        return dateFormatter
    }

    var year: Int {
        return calendar.component(.year, from: self)
    }

    var month: Int {
        return calendar.component(.month, from: self)
    }

    var dayOfWeek: Int {
        return calendar.component(.weekday, from: self)
    }

    var day: Int {
        return calendar.component(.day, from: self)
    }

    var hour: Int {
        return calendar.component(.hour, from: self)
    }

    var minute: Int {
        return calendar.component(.minute, from: self)
    }

    var second: Int {
        return calendar.component(.second, from: self)
    }

    var dayOfWeekString: String {
        return dateFormatter.weekdaySymbols[self.dayOfWeek - 1]
    }

    var dayOfWeekShortString: String {
        return dateFormatter.shortWeekdaySymbols[self.dayOfWeek - 1]
    }

    var japaneseDayOfWeekString: String {
        let dateFormatter = self.dateFormatter
        dateFormatter.locale = Locale(identifier: "ja")
        return dateFormatter.weekdaySymbols[self.dayOfWeek - 1]
    }

    var japaneseDayOfWeekShortString: String {
        let dateFormatter = self.dateFormatter
        dateFormatter.locale = Locale(identifier: "ja")
        return dateFormatter.shortWeekdaySymbols[self.dayOfWeek - 1]
    }


    // MARK: - Internal functions

    func toString(with dateFormatType: DateFormatType? = nil, locale: Locale? = nil) -> String {
        let dateFormatter = self.dateFormatter
        dateFormatter.dateFormat = dateFormatType?.rawValue ?? dateFormatter.dateFormat
        if let locale = locale {
            dateFormatter.locale = locale
        }
        return dateFormatter.string(from: self)
    }
}

extension Date {

    static func + (lhs: Date, rhs: TimeInterval) -> Date {
        return lhs.addingTimeInterval(rhs)
    }
}
