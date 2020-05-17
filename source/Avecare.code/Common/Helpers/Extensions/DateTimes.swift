import UIKit
import CocoaLumberjack



struct DateConfig {
    //    static let ISO8601dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZ"   // UTC+TZ, eg. 2018-10-15T16:29:32.024000-04:00
    static let ISO8601dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"   // UTC Zulu, eg. 2020-15-15T20:39:07.486Z
    static let ISO8601filedateFormat = "yyyyMMdd'T'HHmm"            // eg. 20201520T2139
    static let ISO8601local24hrFormat = "yyyy-MM-dd'T'HH:mm:ss"     // eg. 2020-05-16T15:31:22
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

    // Good for saving file names.
    static func shortISO8601FileStringFromDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = DateConfig.ISO8601filedateFormat

        return dateFormatter.string(from: date)
    }

    static func local24hrFormatISO8601StringFromDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = DateConfig.ISO8601local24hrFormat

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

    static var monthDayYearFormatter: DateFormatter {
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

//    static var fullFormatter: DateFormatter {
//        let formatter = DateFormatter()
//        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"
//        return formatter
//    }

    static var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mma"
        return formatter
    }

}


// MARK: -

extension Date {

    enum Weekday: Int {
        case sunday = 1, monday, tuesday, wednesday, thursday, friday, saturday
    }

//    func isTheSameDay(withDate date: Date) -> Bool {
//        let calendar = Calendar.current
//        return calendar.component(.year, from: self) == calendar.component(.year, from: date) &&
//            calendar.component(.month, from: self) == calendar.component(.month, from: date) &&
//            calendar.component(.day, from: self) == calendar.component(.day, from: date)
//    }

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

}
