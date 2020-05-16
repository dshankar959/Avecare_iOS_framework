import UIKit
import CocoaLumberjack

struct DateConfig {
//    static let ISO8601dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZ"   // GMT+TZ
    static let ISO8601dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"      // local time without TZ
}

extension Date {

    static func ISO8601StringFromDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = DateConfig.ISO8601dateFormat

        return dateFormatter.string(from: date)
    }

    static func dateFromISO8601String(_ string: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone.autoupdatingCurrent
        dateFormatter.dateFormat = DateConfig.ISO8601dateFormat

        return dateFormatter.date(from: string)
    }

    static func shortISO8601FileStringFromDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyyMMdd'T'HHmm"

        return dateFormatter.string(from: date)
    }

    static func localFormatISO8601StringFromDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"

        return dateFormatter.string(from: date)
    }

    // Date to milliseconds and back to date in Swift.
    // https://stackoverflow.com/a/46294917/7599
    var millisecondsSince1970: Int64 {
        return Int64((self.timeIntervalSince1970 * 1000.0).rounded())
    }

    init(milliseconds: Int) {
        self = Date(timeIntervalSince1970: TimeInterval(milliseconds / 1000))
    }

    // MARK: -

    static var ymdFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }

    // TODO: rename it
    static var ymdFormatter2: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd, yyyy"
        return formatter
    }

    static var shortMonthTimeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, hh:mm a"
        return formatter
    }

    static var fullMonthDayFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d"
        return formatter
    }

    static var fullFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"
        return formatter
    }

    static var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mma"
        return formatter
    }

    func isTheSameDay(withDate date: Date) -> Bool {
        let calendar = Calendar.current
        return calendar.component(.year, from: self) == calendar.component(.year, from: date) &&
            calendar.component(.month, from: self) == calendar.component(.month, from: date) &&
            calendar.component(.day, from: self) == calendar.component(.day, from: date)
    }

    func next(_ weekday: Weekday,
              includingTheDate: Bool = false) -> Date {
        let calendar = Calendar(identifier: .gregorian)
        let components = DateComponents(weekday: weekday.rawValue)

        if includingTheDate &&
            calendar.component(.weekday, from: self) == weekday.rawValue {
            return self
        }

        return calendar.nextDate(after: self,
                                 matching: components,
                                 matchingPolicy: .nextTime,
                                 direction: .forward)!
    }

    func previous(_ weekday: Weekday,
                  includingTheDate: Bool = false) -> Date {
        let calendar = Calendar(identifier: .gregorian)
        let components = DateComponents(weekday: weekday.rawValue)

        if includingTheDate &&
            calendar.component(.weekday, from: self) == weekday.rawValue {
            return self
        }

        return calendar.nextDate(after: self,
                                 matching: components,
                                 matchingPolicy: .nextTime,
                                 direction: .backward)!
    }

   enum Weekday: Int {
        case sunday = 1, monday, tuesday, wednesday, thursday, friday, saturday
    }
}
