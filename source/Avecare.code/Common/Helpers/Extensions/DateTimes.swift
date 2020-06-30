import UIKit
import CocoaLumberjack



extension Date {

    static func ISO8601StringFromDate(_ date: Date) -> String {
        let dateFormatter = ISO8601Formatter
        return dateFormatter.string(from: date)
    }

    static func dateFromISO8601String(_ string: String) -> Date? {
        let dateFormatter = ISO8601Formatter
        return dateFormatter.date(from: string)
    }

    // log form API
    static func logFormStringFromDate(_ date: Date) -> String {
        let dateFormatter = yearMonthDayFormatter
        return dateFormatter.string(from: date)
    }

    // log form API
    static func dateFromLogFormString(_ string: String) -> Date? {
        let dateFormatter = yearMonthDayFormatter
        return dateFormatter.date(from: string)
    }

    // Good for saving file names.
    static func shortISO8601FileStringFromDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyyMMdd'T'HHmm"        // eg. 20201520T2139

        return dateFormatter.string(from: date)
    }

    static func local24hrFormatISO8601StringFromDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"  // eg. 2020-05-16T15:31:22

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

    static var ISO8601Formatter: ISO8601DateFormatter {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions.insert(.withFractionalSeconds)
        return formatter
    }

    static var yearMonthDayFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"     // eg. 2020-05-27
        return formatter
    }

    static var monthDayYearFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd, yyyy"
        return formatter
    }

    static var fullMonthDayYearFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d, yyyy"
        return formatter
    }

    static var shortMonthTimeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, hh:mm a"
        return formatter
    }

    static var fullMonthTimeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d, hh:mm a"
        return formatter
    }

    static var fullMonthDayFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d"
        return formatter
    }

    static var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mma"
        return formatter
    }

}


// MARK: -

private let YearKey = "{year}"
private let MonthKey = "{month}"
private let WeekKey = "{week}"
private let DayKey = "{day}"
private let HourKey = "{hour}"
private let MinuteKey = "{minute}"
private let SecondKey = "{second}"

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

    var startOfDay: Date {
        return Calendar.current.startOfDay(for: self)
    }

    var endOfDay: Date {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfDay)!
    }

    var startOfMonth: Date {
        let components = Calendar.current.dateComponents([.year, .month], from: startOfDay)
        return Calendar.current.date(from: components)!
    }

    var endOfMonth: Date {
        var components = DateComponents()
        components.month = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfMonth)!
    }

    func timeAgo(numericDates: Bool = false, dayAbove: Bool = true) -> String {
        let calendar = Calendar.current
        let unitFlags: Set<Calendar.Component> = [.minute, .hour, .day, .weekOfMonth, .month, .year, .second]
        let components: DateComponents = calendar.dateComponents(unitFlags, from: self)
        let componentsOfNow: DateComponents = calendar.dateComponents(unitFlags, from: Date())

        let year = (componentsOfNow.year ?? 0) - (components.year ?? 0)
        let month = (componentsOfNow.month ?? 0) - (components.month ?? 0)
        let weekOfMonth = (componentsOfNow.weekOfMonth ?? 0) - (components.weekOfMonth ?? 0)
        let day = (componentsOfNow.day ?? 0) - (components.day ?? 0)
        let hour = (componentsOfNow.hour ?? 0) - (components.hour ?? 0)
        let minute = (componentsOfNow.minute ?? 0) - (components.minute ?? 0)
        let second = (componentsOfNow.second ?? 0) - (components.second ?? 0)

        if self < Date() {
            switch (year, month, weekOfMonth, day, hour, minute, second) {
            case (let year, _, _, _, _, _, _) where year >= 2:
                let result = NSLocalizedString("time_ago_years_ago", comment: "")
                return result.replacingOccurrences(of: YearKey, with: "\(year)")
            case (let year, _, _, _, _, _, _) where year == 1 && numericDates: return NSLocalizedString("time_ago_1_year_ago", comment: "")
            case (let year, _, _, _, _, _, _) where year == 1 && !numericDates: return NSLocalizedString("time_ago_last", comment: "")
            case (_, let month, _, _, _, _, _) where month >= 2:
                let result = NSLocalizedString("time_ago_months_ago", comment: "")
                return result.replacingOccurrences(of: MonthKey, with: "\(month)")
            case (_, let month, _, _, _, _, _) where month == 1 && numericDates: return NSLocalizedString("time_ago_1_month_ago", comment: "")
            case (_, let month, _, _, _, _, _) where month == 1 && !numericDates: return NSLocalizedString("time_ago_last_month", comment: "")
            case (_, _, let weekOfMonth, _, _, _, _) where weekOfMonth >= 2:
                let result = NSLocalizedString("time_ago_weeks_ago", comment: "")
                return result.replacingOccurrences(of: WeekKey, with: "\(weekOfMonth)")
            case (_, _, let weekOfMonth, _, _, _, _) where weekOfMonth == 1 && numericDates: return NSLocalizedString("time_ago_1_week_ago", comment: "")
            case (_, _, let weekOfMonth, _, _, _, _) where weekOfMonth == 1 && !numericDates: return NSLocalizedString("time_ago_last_week", comment: "")
            case (_, _, _, let day, _, _, _) where day >= 2:
                let result = NSLocalizedString("time_ago_days_ago", comment: "")
                return result.replacingOccurrences(of: DayKey, with: "\(day)")
            case (_, _, _, let day, _, _, _) where day == 1 && numericDates: return NSLocalizedString("time_ago_1_day_ago", comment: "")
            case (_, _, _, let day, _, _, _) where day == 1 && !numericDates: return NSLocalizedString("time_ago_yesterday", comment: "")
            case (_, _, _, _, _, _, _) where dayAbove: return NSLocalizedString("time_ago_today", comment: "")
            case (_, _, _, _, let hour, _, _) where hour >= 2:
                let result = NSLocalizedString("time_ago_hours_ago", comment: "")
                return result.replacingOccurrences(of: HourKey, with: "\(hour)")
            case (_, _, _, _, let hour, _, _) where hour == 1 && numericDates: return NSLocalizedString("time_ago_1_hour_ago", comment: "")
            case (_, _, _, _, let hour, _, _) where hour == 1 && !numericDates: return NSLocalizedString("time_ago_an_hour_ago", comment: "")
            case (_, _, _, _, _, let minute, _) where minute >= 2:
                let result = NSLocalizedString("time_ago_minutes_ago", comment: "")
                return result.replacingOccurrences(of: MinuteKey, with: "\(minute)")
            case (_, _, _, _, _, let minute, _) where minute == 1 && numericDates: return NSLocalizedString("time_ago_1_minute_ago", comment: "")
            case (_, _, _, _, _, let minute, _) where minute == 1 && !numericDates: return NSLocalizedString("time_ago_a_minute_ago", comment: "")
            case (_, _, _, _, _, _, let second) where second >= 3:
                let result = NSLocalizedString("time_ago_seconds_ago", comment: "")
                return result.replacingOccurrences(of: SecondKey, with: "\(second)")
            default: return NSLocalizedString("time_ago_just_now", comment: "")
            }
        } else {
            switch (year, month, weekOfMonth, day, hour, minute, second) {
            case (let year, _, _, _, _, _, _) where year <= -2:
                let result = NSLocalizedString("time_ago_years_future", comment: "")
                return result.replacingOccurrences(of: YearKey, with: "\(year)")
            case (let year, _, _, _, _, _, _) where year == -1 && numericDates: return NSLocalizedString("time_ago_1_year_future", comment: "")
            case (let year, _, _, _, _, _, _) where year == -1 && !numericDates: return NSLocalizedString("time_ago_next_year", comment: "")
            case (_, let month, _, _, _, _, _) where month <= -2:
                let result = NSLocalizedString("time_ago_months_future", comment: "")
                return result.replacingOccurrences(of: MonthKey, with: "\(month)")
            case (_, let month, _, _, _, _, _) where month == -1 && numericDates: return NSLocalizedString("time_ago_1_month_future", comment: "")
            case (_, let month, _, _, _, _, _) where month == -1 && !numericDates: return NSLocalizedString("time_ago_next_month", comment: "")
            case (_, _, let weekOfMonth, _, _, _, _) where weekOfMonth <= -2:
                let result = NSLocalizedString("time_ago_weeks_future", comment: "")
                return result.replacingOccurrences(of: WeekKey, with: "\(weekOfMonth)")
            case (_, _, let weekOfMonth, _, _, _, _) where weekOfMonth == -1 && numericDates: return NSLocalizedString("time_ago_1_week_future", comment: "")
            case (_, _, let weekOfMonth, _, _, _, _) where weekOfMonth == -1 && !numericDates: return NSLocalizedString("time_ago_next_week", comment: "")
            case (_, _, _, let day, _, _, _) where day <= -2:
                let result = NSLocalizedString("time_ago_days_future", comment: "")
                return result.replacingOccurrences(of: DayKey, with: "\(day)")
            case (_, _, _, let day, _, _, _) where day == -1 && numericDates: return NSLocalizedString("time_ago_1_day_future", comment: "")
            case (_, _, _, let day, _, _, _) where day == -1 && !numericDates: return NSLocalizedString("time_ago_tomorrow", comment: "")
            case (_, _, _, _, _, _, _) where dayAbove: return NSLocalizedString("time_ago_today", comment: "")
            case (_, _, _, _, let hour, _, _) where hour <= -2:
                let result = NSLocalizedString("time_ago_hours_future", comment: "")
                return result.replacingOccurrences(of: HourKey, with: "\(hour)")
            case (_, _, _, _, let hour, _, _) where hour == -1 && numericDates: return NSLocalizedString("time_ago_1_hour_future", comment: "")
            case (_, _, _, _, let hour, _, _) where hour == -1 && !numericDates: return NSLocalizedString("time_ago_an_hour_future", comment: "")
            case (_, _, _, _, _, let minute, _) where minute <= -2:
                let result = NSLocalizedString("time_ago_minutes_future", comment: "")
                return result.replacingOccurrences(of: MinuteKey, with: "\(minute)")
            case (_, _, _, _, _, let minute, _) where minute == -1 && numericDates: return NSLocalizedString("time_ago_1_minute_future", comment: "")
            case (_, _, _, _, _, let minute, _) where minute == -1 && !numericDates: return NSLocalizedString("time_ago_a_minute_future", comment: "")
            case (_, _, _, _, _, _, let second) where second <= -3:
                let result = NSLocalizedString("time_ago_seconds_future", comment: "")
                return result.replacingOccurrences(of: SecondKey, with: "\(second)")
            default: return NSLocalizedString("time_ago_just_now", comment: "")
            }
        }
    }

    var dateStringHumanFriendly: String {
        return Date.fullMonthDayYearFormatter.string(from: self)
    }

    var dateStringWithDayOfWeekHumanFriendly: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d, yyyy"
        return formatter.string(from: self)
    }

    var dateTimeStringHumanFriendly: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a, MMMM d, yyyy"
        return formatter.string(from: self)
    }
}
