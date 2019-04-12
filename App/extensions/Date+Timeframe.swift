import Foundation


extension Date {
    
    public enum DayOfWeek: Int {
        case monday = 0
        case tuesday = 1
        case wednesday = 2
        case thursday = 3
        case friday = 4
        case saturday = 5
        case sunday = 6
    }
    
    public class Timeframe {
        
        static var today : Timeframe { return Timeframe.day(Date()) }
        static var yesterday : Timeframe { return today.timeframeByAddingTimeInterval(days: -1) }
        static var currentWeek : Timeframe { return Timeframe.week(Date()) }
        static var lastWeek : Timeframe { return currentWeek.timeframeByAddingTimeInterval(weeks: -1) }
        
        let from: Date?
        let to: Date?
        
        init (fromDate: Date? = nil, toDate: Date? = nil) {
            self.from = fromDate
            self.to = toDate
        }
        
        //Returns the day of the given date as Timeframe. A day is from 00:00:00 to 23:59:59
        class func day(_ date: Date) -> Timeframe {
            let todayZero = date.dayZero()
            return Timeframe(fromDate: todayZero, toDate: todayZero.date(byAddingDays: 1).addingTimeInterval(-1))
        }
        
        //Returns the week of the given date as Timeframe. A week is from monday 00:00:00 to sunday 23:59:59
        class func week(_ date: Date) -> Timeframe {
            let weekZero = date.weekZero()
            return Timeframe(fromDate: weekZero, toDate: weekZero.date(byAddingWeeks: 1).addingTimeInterval(-1))
        }
        
        func timeframeByAddingTimeInterval (days count: Int) -> Timeframe {
            return Timeframe(fromDate: self.from?.date(byAddingDays: count),
                             toDate: self.to?.date(byAddingDays: count))
        }
        
        func timeframeByAddingTimeInterval (weeks count: Int) -> Timeframe {
            return Timeframe(fromDate: self.from?.date(byAddingWeeks: count),
                             toDate: self.to?.date(byAddingWeeks: count))
        }
        
        func timeframeByAddingTimeInterval (ti: TimeInterval) -> Timeframe {
            return Timeframe(fromDate: self.from?.addingTimeInterval(ti),
                             toDate: self.to?.addingTimeInterval(ti))
        }
        
        //Adds the given interval to the end
        func timeframeByExtending (ti: TimeInterval) -> Timeframe {
            return Timeframe(fromDate: self.from, toDate: self.to?.addingTimeInterval(ti))
        }
        
        //Adds the given interval before the timeframe
        func timeframeByStartingEarlier (ti: TimeInterval) -> Timeframe {
            return Timeframe(fromDate: self.from?.addingTimeInterval(-ti), toDate: self.to)
        }
        
        //Returns all occurences of the given day in this timeframe
        func get (_ day: DayOfWeek) -> Array<Date> {
            var result = Array<Date>()
            if (self.from == nil && self.to == nil) {
                return result;
            }
            let weekZero = self.from?.weekZero() ?? self.to!.weekZero()
            result.append(weekZero.date(byAddingDays: day.rawValue))
            while (result.last!.date(byAddingWeeks: 1).isLessThanDate(self.to ?? self.from!)) {
                result.append(result.last!.date(byAddingWeeks: 1))
            }
            return result
        }
        
    }
    
    public func isIn (_ timeframe: Timeframe?) -> Bool {
        
        if let tf = timeframe {
            var result: Bool = true
            
            //if after fromDate (in case we have a fromDate)
            if let date = tf.from {
                if self.isLessThanDate(date) {
                    result = false
                }
            }
            
            //if before toDate (in case we have a toDate)
            if let date =  tf.to {
                if self.isGreaterThanDate(date) {
                    result = false
                }
            }
            
            return result
        } else {
            return true
        }
        
    }
    
    public static func timeframe (_ fromDate: Date, toDate: Date) -> Timeframe {
        return Timeframe.init(fromDate: fromDate, toDate: toDate)
    }
    
    public static func timeframe (fromDate date: Date) -> Timeframe {
        return Timeframe.init(fromDate: date)
    }
    
    public static func timeframe (toDate date: Date) -> Timeframe {
        return Timeframe.init(toDate: date)
    }
    
    public static func dayTimeframe (_ date : Date) -> Timeframe {
        return Timeframe.day(date)
    }
    
    public func weekTimeframe () -> Timeframe {
        return Timeframe.week(self)
    }
    
    
    func toReadableString (_ showTime: Bool = true) -> String {
        var date: String = self.toDisplayString(true, showTime: false)
        if self.isIn(.today) {
            date = "Today\(showTime ? "," : "")"
        } else if self.isIn(.yesterday) {
            date = "Yesterday\(showTime ? "," : "")"
        } else if self.isIn(.currentWeek) {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "EEEE"
            let day = dateFormatter.string(from: self)
            date = "\(day)\(showTime ? "," : "")"
        }
        return "\(showTime ? "\(date) \(self.toDisplayString(false, showTime: true))" : date)"
    }
    
    
    static func timeIntervalMinute () -> TimeInterval {
        return 60
    }
    
    static func timeIntervalHour () -> TimeInterval {
        return 60 * 60
    }
    static func timeIntervalDay () -> TimeInterval {
        return 60 * 60 * 24
    }
    static func timeIntervalWeek () -> TimeInterval {
        return 60 * 60 * 24 * 7
    }
    
    func isGreaterThanDate(_ dateToCompare: Date) -> Bool {
        //Declare Variables
        var isGreater = false
        
        //Compare Values
        if self.compare(dateToCompare) == ComparisonResult.orderedDescending {
            isGreater = true
        }
        
        //Return Result
        return isGreater
    }
    
    func isAfter (_ date: Date) -> Bool {
        return isGreaterThanDate(date)
    }
    
    func isBefore (_ date: Date) -> Bool {
        return isLessThanDate(date)
    }
    
    func isLessThanDate(_ dateToCompare: Date) -> Bool {
        //Declare Variables
        var isLess = false
        
        //Compare Values
        if self.compare(dateToCompare) == ComparisonResult.orderedAscending {
            isLess = true
        }
        
        //Return Result
        return isLess
    }
    
    func equalToDate(_ dateToCompare: Date) -> Bool {
        //Declare Variables
        var isEqualTo = false
        
        //Compare Values
        if self.compare(dateToCompare) == ComparisonResult.orderedSame {
            isEqualTo = true
        }
        
        //Return Result
        return isEqualTo
    }
    
    func daysFrom(_ to : Date) -> Int {
        let calendar = Calendar.current
        
        let startDate = calendar.startOfDay(for: self)
        let endDate = calendar.startOfDay(for: to)
        
        let flags = NSCalendar.Unit.day
        let components = (calendar as NSCalendar).components(flags, from: startDate, to: endDate, options: [])
        
        return components.day!
    }
    
    func timeIntervalSinceDate (_ anotherDate: Date, inTimeInterval: TimeInterval) -> Double {
        return self.timeIntervalSince(anotherDate) / inTimeInterval
    }
    
    public static func dateWith (_ year: Int, month: Int, day: Int) -> Date {
        let calendar = Calendar.current
        var components = (calendar as NSCalendar).components([NSCalendar.Unit.year, NSCalendar.Unit.month, NSCalendar.Unit.day], from: Date.init())
        components.day = day
        components.month = month
        components.year = year
        
        return calendar.date(from: components)!
    }
    
    func minutesFrom(_ date: Date) -> Int{
        return (Calendar.current as NSCalendar).components(.minute, from: date, to: self, options: []).minute!
    }
    
    func toDisplayString (_ showDate: Bool = true, showTime: Bool = false) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "\(showDate ? "dd.MM.yyyy" : "")\(showDate && showTime ? " " : "")\(showTime ? "HH:mm" : "")"
        return dateFormatter.string(from: self)
    }
    
    func date (byAddingMinutes count: Int) -> Date {
        return self.addingTimeInterval(Double(count) * Date.timeIntervalMinute())
    }
    
    func date (byAddingHours count: Int) -> Date {
        return self.addingTimeInterval(Double(count) * Date.timeIntervalHour())
    }
    
    func date (byAddingDays count: Int) -> Date {
        return self.addingTimeInterval(Double(count) * Date.timeIntervalDay())
    }
    
    func date (byAddingWeeks count: Int) -> Date {
        return self.addingTimeInterval(Double(count) * Date.timeIntervalWeek())
    }
    
    //Returns the date of today 00:00:00
    func dayZero () -> Date {
        var beginningOfDay = Date()
        var interval: TimeInterval = 0
        
        _ = Calendar.current.dateInterval(of: .day, start: &beginningOfDay, interval: &interval, for: self)
        
        return beginningOfDay
    }
    
    //Returns dayZero of the first day of the month this date is in
    func monthZero () -> Date {
        var beginningOfMonth = Date()
        var interval: TimeInterval = 0
        
        _ = Calendar.current.dateInterval(of: .month, start: &beginningOfMonth, interval: &interval, for: self)
        
        return beginningOfMonth
    }
    
    //Returns dayZero of the first day of the year this date is in
    func yearZero () -> Date {
        var beginningOfYear = Date()
        var interval: TimeInterval = 0
        
        _ = Calendar.current.dateInterval(of: .year, start: &beginningOfYear, interval: &interval, for: self)
        
        
        return beginningOfYear
    }
    
    //Returns the date of last monday 00:00:00 (same as todayZero if today is monday)
    func weekZero () -> Date {
        var beginningOfWeek = Date()
        var interval: TimeInterval = 0
        
        _ = Calendar.current.dateInterval(of: .weekOfYear, start: &beginningOfWeek, interval: &interval, for: self)
        
        return beginningOfWeek
    }
    
}
