import Foundation

class ChineseCalendarHelper {
    // 添加缓存日历实例
    private static let gregorianCalendar = Calendar.current
    private static let chineseCalendar = Calendar(identifier: .chinese)
    
    // 法定节假日数据 (使用新的 HolidayManager)
    private static let holidays: [String: String] = [
        "01-01": "元旦",
        "05-01": "劳动节",
        "10-01": "国庆节",
        // 农历节日需要特殊处理
        // 春节、清明、端午、中秋等节日将通过 HolidayManager 处理
    ]
    
    // 农历月份名称
    private static let chineseMonths = ["正", "二", "三", "四", "五", "六", "七", "八", "九", "十", "冬", "腊"]
    
    // 农历日期名称
    private static let chineseDays = ["初一", "初二", "初三", "初四", "初五", "初六", "初七", "初八", "初九", "初十", "十一", "十二", "十三", "十四", "十五", "十六", "十七", "十八", "十九", "二十", "廿一", "廿二", "廿三", "廿四", "廿五", "廿六", "廿七", "廿八", "廿九", "三十"]
    
    // 天干
    private static let heavenlyStems = ["甲", "乙", "丙", "丁", "戊", "己", "庚", "辛", "壬", "癸"]
    
    // 地支
    private static let earthlyBranches = ["子", "丑", "寅", "卯", "辰", "巳", "午", "未", "申", "酉", "戌", "亥"]
    
    // 生肖
    private static let animals = ["鼠", "牛", "虎", "兔", "龙", "蛇", "马", "羊", "猴", "鸡", "狗", "猪"]
    
    // 24节气数据 (示例，请替换为实际数据)
    private static let solarTerms: [String: String] = [
        "01-06": "小寒",
        "01-20": "大寒",
        "02-04": "立春",
        "02-19": "雨水",
        "03-05": "惊蛰",
        "03-20": "春分",
        "04-04": "清明",
        "04-19": "谷雨",
        "05-05": "立夏",
        "05-21": "小满",
        "06-05": "芒种",
        "06-21": "夏至",
        "07-06": "小暑",
        "07-22": "大暑",
        "08-07": "立秋",
        "08-22": "处暑",
        "09-07": "白露",
        "09-22": "秋分",
        "10-08": "寒露",
        "10-23": "霜降",
        "11-07": "立冬",
        "11-22": "小雪",
        "12-06": "大雪",
        "12-21": "冬至"
    ]
    
    // 获取当前年份的天干地支和生肖
    static func getChineseYearText(for date: Date) -> String {
        let year = gregorianCalendar.component(.year, from: date)
        let stemIndex = (year - 4) % 10
        let branchIndex = (year - 4) % 12
        let animalIndex = (year - 4) % 12
        
        let stem = heavenlyStems[stemIndex]
        let branch = earthlyBranches[branchIndex]
        let animal = animals[animalIndex]
        
        return "\(stem)\(branch)·\(animal)年"
    }
    
    // 获取农历月份
    static func getChineseMonth(for date: Date) -> String {
        let components = chineseCalendar.dateComponents([.month], from: date)
        let month = components.month ?? 1
        
        return chineseMonths[month - 1]
    }
    
    // 获取农历日期
    static func getChineseDay(for date: Date) -> String {
        let components = chineseCalendar.dateComponents([.day, .month], from: date)
        let day = components.day ?? 1
        let month = components.month ?? 1
        
        // 如果是初一，显示月份
        if day == 1 {
            return "\(chineseMonths[month - 1])月"
        } else {
            return chineseDays[day - 1]
        }
    }
    
    // 判断是否为法定节假日
    static func isHoliday(_ date: Date) -> Bool {
        print("ChineseCalendarHelper.isHoliday called with date: \(date)")
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd"
        let dateString = formatter.string(from: date)
        
        // 先检查固定日期的节假日
        if holidays[dateString] != nil && !holidays[dateString]!.isEmpty {
            print("Found fixed holiday: \(dateString)")
            return true
        }
        
        // 再检查通过 HolidayManager 管理的节假日
        let year = gregorianCalendar.component(.year, from: date)
        let monthDayFormatter = DateFormatter()
        monthDayFormatter.dateFormat = "MMdd"
        let monthDayString = monthDayFormatter.string(from: date)
        
        print("Checking HolidayManager for year: \(year), monthDay: \(monthDayString)")
        if let holidayType = HolidayManager.default.typeOf(year: year, monthDay: monthDayString) {
            print("Found holiday from HolidayManager: \(year)-\(monthDayString) type: \(holidayType)")
            return holidayType == .holiday
        }
        
        return false
    }
    
    // 判断是否为调休上班日
    static func isWorkday(_ date: Date) -> Bool {
        let year = gregorianCalendar.component(.year, from: date)
        let monthDayFormatter = DateFormatter()
        monthDayFormatter.dateFormat = "MMdd"
        let monthDayString = monthDayFormatter.string(from: date)
        
        if let holidayType = HolidayManager.default.typeOf(year: year, monthDay: monthDayString) {
            return holidayType == .workday
        }
        return false
    }
    
    // 获取节假日名称
    static func holidayName(for date: Date) -> String? {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd"
        let dateString = formatter.string(from: date)
        
        // 先检查固定日期的节假日
        if let name = holidays[dateString], !name.isEmpty {
            print("Found fixed holiday name: \(dateString) - \(name)")
            return name
        }
        
        // 再检查通过 HolidayManager 管理的节假日
        let year = gregorianCalendar.component(.year, from: date)
        let monthDayFormatter = DateFormatter()
        monthDayFormatter.dateFormat = "MMdd"
        let monthDayString = monthDayFormatter.string(from: date)
        
        if let holidayType = HolidayManager.default.typeOf(year: year, monthDay: monthDayString) {
            if holidayType == .holiday {
                print("Found holiday name from HolidayManager: \(year)-\(monthDayString)")
                // 对于通过 HolidayManager 管理的节假日，我们需要映射到具体的名称
                // 这里可以根据实际需求进行扩展
                switch monthDayString {
                case "0101": return "元旦"
                case "0501": return "劳动节"
                case "1001": return "国庆节"
                default: return "节假日"
                }
            }
        }
        
        return nil
    }
    
    // 别名方法，保持与之前版本的兼容性
    static func isHolidaySync(_ date: Date) -> Bool {
        return isHoliday(date)
    }
    
    static func isWorkdaySync(_ date: Date) -> Bool {
        return isWorkday(date)
    }
    
    static func holidayNameSync(for date: Date) -> String? {
        return holidayName(for: date)
    }
    
    // 获取当前是一年中的第几天
    static func dayOfYear(for date: Date) -> Int {
        return gregorianCalendar.ordinality(of: .day, in: .year, for: date) ?? 0
    }
    
    // 获取当前是一年中的第几周
    static func weekOfYear(for date: Date) -> Int {
        return gregorianCalendar.component(.weekOfYear, from: date) + 1
    }
    
    // 判断日期是否为24节气
    static func isSolarTerm(_ date: Date) -> Bool {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd"
        let dateString = formatter.string(from: date)
        return solarTerms[dateString] != nil
    }
    
    // 获取节气名称
    static func solarTermName(for date: Date) -> String? {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd"
        let dateString = formatter.string(from: date)
        return solarTerms[dateString]
    }
}