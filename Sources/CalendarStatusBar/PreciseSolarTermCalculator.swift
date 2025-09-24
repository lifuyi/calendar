import Foundation

/// 精确节气计算器 - 基于天文算法计算二十四节气
public class PreciseSolarTermCalculator {
    // 24节气名称 (按照黄经顺序排列，从春分点0°开始)
    private static let solarTermNames = [
        "春分", "清明", "谷雨", "立夏", "小满", "芒种",
        "夏至", "小暑", "大暑", "立秋", "处暑", "白露",
        "秋分", "寒露", "霜降", "立冬", "小雪", "大雪",
        "冬至", "小寒", "大寒", "立春", "雨水", "惊蛰"
    ]
    
    // 节气对应的太阳黄经度数（从春分点0°开始，每隔15°一个节气）
    private static let solarTermLongitudes: [Double] = [
        0, 15, 30, 45, 60, 75, 90, 105, 120, 135, 150, 165,
        180, 195, 210, 225, 240, 255, 270, 285, 300, 315, 330, 345
    ]
    
    /// 计算指定年份和节气索引的精确时刻
    /// - Parameters:
    ///   - year: 年份
    ///   - termIndex: 节气索引 (0-23)
    /// - Returns: 节气的精确时刻，如果计算失败返回nil
    public static func calculateSolarTermDate(year: Int, termIndex: Int) -> Date? {
        // 使用已知的基准日期进行计算
        // 2000年春分：2000年3月20日 07:35 UTC
        let referenceDate = Calendar.current.date(from: DateComponents(year: 2000, month: 3, day: 20, hour: 7, minute: 35))!
        let referenceYear = 2000
        
        // 计算年份差
        let yearDiff = Double(year - referenceYear)
        
        // 每年平均365.2422天
        let daysPerYear = 365.2422
        
        // 每个节气平均间隔15.2184天
        let daysPerTerm = daysPerYear / 24.0
        
        // 计算从基准日期到目标年份春分的天数
        let daysToTargetSpringEquinox = yearDiff * daysPerYear
        
        // 计算到目标节气的天数
        let daysToTargetTerm = daysToTargetSpringEquinox + Double(termIndex) * daysPerTerm
        
        // 初始估算日期
        guard let initialDate = Calendar.current.date(byAdding: .day, value: Int(daysToTargetTerm), to: referenceDate) else {
            return nil
        }
        
        // 获取节气对应的黄经度数
        let targetLongitude = solarTermLongitudes[termIndex]
        
        // 使用迭代法精确计算
        var currentDate = initialDate
        let calendar = Calendar.current
        let maxIterations = 10
        let tolerance = 0.001 // 容差（度）
        
        for _ in 0..<maxIterations {
            // 计算当前日期的太阳黄经
            let currentLongitude = sunEclipticLongitude(currentDate)
            
            // 计算与目标黄经的差值
            var diff = targetLongitude - currentLongitude
            
            // 处理角度跨越问题
            if diff > 180 { diff -= 360 }
            if diff < -180 { diff += 360 }
            
            // 如果差值足够小，返回结果
            if abs(diff) < tolerance {
                return currentDate
            }
            
            // 计算太阳移动速率（度/天）
            let meanMotion = 0.985647352 // 太阳平均每日移动度数
            
            // 计算需要调整的天数
            let daysAdjustment = diff / meanMotion
            
            // 调整日期
            guard let newDate = calendar.date(byAdding: .second, 
                                            value: Int(daysAdjustment * 86400), 
                                            to: currentDate) else { break }
            currentDate = newDate
        }
        
        return currentDate
    }
    
    /// 获取指定日期的节气信息
    /// - Parameter date: 日期
    /// - Returns: 节气索引和名称的元组，如果不是节气则返回(-1, nil)
    public static func solarTermInfo(for date: Date) -> (index: Int, name: String?) {
        let calendar = Calendar.current
        let year = calendar.component(.year, from: date)
        let targetComponents = calendar.dateComponents([.year, .month, .day], from: date)
        
        // 检查当年所有节气
        for i in 0..<solarTermLongitudes.count {
            // 计算节气的精确时刻
            if let termDate = calculateSolarTermDate(year: year, termIndex: i) {
                let termComponents = calendar.dateComponents([.year, .month, .day], from: termDate)
                
                // 如果日期匹配，则为节气
                if termComponents.year == targetComponents.year && 
                   termComponents.month == targetComponents.month && 
                   termComponents.day == targetComponents.day {
                    return (i, solarTermNames[i])
                }
            }
        }
        
        // 检查前一年的最后几个节气（可能跨年）
        if let lastYearDate = calendar.date(byAdding: .year, value: -1, to: date) {
            let lastYear = calendar.component(.year, from: lastYearDate)
            
            // 检查前一年的最后4个节气（冬至、小寒、大寒、立春）
            for i in stride(from: 20, through: 23, by: 1) {
                if let termDate = calculateSolarTermDate(year: lastYear, termIndex: i) {
                    let termComponents = calendar.dateComponents([.year, .month, .day], from: termDate)
                    
                    if termComponents.year == targetComponents.year && 
                       termComponents.month == targetComponents.month && 
                       termComponents.day == targetComponents.day {
                        return (i, solarTermNames[i])
                    }
                }
            }
        }
        
        return (-1, nil)
    }
    
    /// 判断日期是否为节气
    /// - Parameter date: 日期
    /// - Returns: 如果是节气返回true，否则返回false
    public static func isSolarTerm(_ date: Date) -> Bool {
        let (_, name) = solarTermInfo(for: date)
        return name != nil
    }
    
    /// 获取节气名称
    /// - Parameter date: 日期
    /// - Returns: 节气名称，如果不是节气返回nil
    public static func solarTermName(for date: Date) -> String? {
        let (_, name) = solarTermInfo(for: date)
        return name
    }
    
    /// 获取指定年份的所有节气日期
    /// - Parameter year: 年份
    /// - Returns: 节气名称和日期的字典
    public static func getAllSolarTerms(for year: Int) -> [String: Date] {
        var terms: [String: Date] = [:]
        
        for i in 0..<solarTermNames.count {
            if let date = calculateSolarTermDate(year: year, termIndex: i) {
                terms[solarTermNames[i]] = date
            }
        }
        
        return terms
    }
    
    // MARK: - 私有辅助方法
    
    /// 使用简化方法计算太阳黄经（度）
    private static func sunEclipticLongitude(_ date: Date) -> Double {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        let year = components.year ?? 0
        let month = components.month ?? 0
        let day = components.day ?? 0
        let hour = components.hour ?? 0
        let minute = components.minute ?? 0
        let second = components.second ?? 0
        
        // 计算儒略日
        let jd = julianDay(year: year, month: month, day: day, hour: hour, minute: minute, second: second)
        
        // 计算儒略世纪数
        let t = (jd - 2451545.0) / 36525.0
        
        // 使用简化公式计算太阳黄经
        var longitude = 280.46645 + 36000.76983 * t + 0.0003032 * t * t
        longitude += (1.914602 - 0.004817 * t - 0.000014 * t * t) * sin(deg2rad(357.52911 + 35999.05029 * t - 0.0001537 * t * t))
        longitude += (0.019993 - 0.000101 * t) * sin(deg2rad(2 * (357.52911 + 35999.05029 * t - 0.0001537 * t * t)))
        longitude += 0.000289 * sin(deg2rad(3 * (357.52911 + 35999.05029 * t - 0.0001537 * t * t)))
        
        // 确保角度在0-360范围内
        longitude = longitude.truncatingRemainder(dividingBy: 360.0)
        if longitude < 0 {
            longitude += 360.0
        }
        
        return longitude
    }
    
    /// 计算儒略日
    private static func julianDay(year: Int, month: Int, day: Int, hour: Int, minute: Int, second: Int) -> Double {
        var y = year
        var m = month
        
        // 如果月份是1月或2月，则将其视为前一年的13月或14月
        if month <= 2 {
            y -= 1
            m += 12
        }
        
        // 儒略日计算
        let a = Int(Double(y) / 100.0)
        let b = 2 - a + Int(Double(a) / 4.0)
        
        let jd = Int(365.25 * Double(y + 4716)) + Int(30.6001 * Double(m + 1)) + day + b - 1524
        
        // 加上时间部分
        let timeFraction = (Double(hour) + Double(minute) / 60.0 + Double(second) / 3600.0) / 24.0
        
        return Double(jd) + timeFraction
    }
    
    /// 角度转弧度
    private static func deg2rad(_ degree: Double) -> Double {
        return degree * Double.pi / 180.0
    }
}