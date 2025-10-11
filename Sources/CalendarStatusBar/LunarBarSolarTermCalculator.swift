import Foundation

/// 基于 LunarBar 数据表的节气计算器
/// 这种方法使用预定义的节气数据表，比公式计算更准确
public class LunarBarSolarTermCalculator {
    // 24节气名称 (按照黄经顺序排列，从立春开始)
    private static let solarTermNames = [
        "立春", "雨水", "惊蛰", "春分", "清明", "谷雨",
        "立夏", "小满", "芒种", "夏至", "小暑", "大暑",
        "立秋", "处暑", "白露", "秋分", "寒露", "霜降",
        "立冬", "小雪", "大雪", "冬至", "小寒", "大寒"
    ]
    
    /// 从 LunarBar 的 data.json 加载节气数据
    private static var solarTermsData: [String: [String: Int]] = [:]
    
    /// 初始化方法，加载节气数据
    public static func initialize() {
        // 尝试从主 bundle 加载数据
        if let path = Bundle.main.path(forResource: "solar_terms_data", ofType: "json"),
           let data = try? Data(contentsOf: URL(fileURLWithPath: path)),
           let json = try? JSONSerialization.jsonObject(with: data) as? [String: [String]] {
            
            // 转换数据格式为 [年份: [月日: 节气索引]]
            for (year, dates) in json {
                var yearData: [String: Int] = [:]
                for (index, date) in dates.enumerated() {
                    yearData[date] = index
                }
                solarTermsData[year] = yearData
            }
        } else {
            // 尝试从模块资源加载数据
            if let url = Bundle.module.url(forResource: "Holidays/solar_terms_data", withExtension: "json"),
               let data = try? Data(contentsOf: url),
               let json = try? JSONSerialization.jsonObject(with: data) as? [String: [String]] {
                
                // 转换数据格式为 [年份: [月日: 节气索引]]
                for (year, dates) in json {
                    var yearData: [String: Int] = [:]
                    for (index, date) in dates.enumerated() {
                        yearData[date] = index
                    }
                    solarTermsData[year] = yearData
                }
            } else {
                // 如果无法从 bundle 加载，使用内置的简化数据
                loadBuiltinData()
            }
        }
    }
    
    /// 加载内置的简化节气数据（2020-2030年）
    private static func loadBuiltinData() {
        // 这里只包含部分年份的数据作为示例
        // 实际应用中应该包含完整的数据表
        solarTermsData = [
            "2023": [
                "0204": 0, "0219": 1, "0306": 2, "0321": 3, "0405": 4, "0420": 5,
                "0506": 6, "0521": 7, "0606": 8, "0621": 9, "0707": 10, "0723": 11,
                "0808": 12, "0823": 13, "0908": 14, "0923": 15, "1008": 16, "1024": 17,
                "1108": 18, "1122": 19, "1207": 20, "1222": 21, "0106": 22, "0120": 23
            ],
            "2024": [
                "0204": 0, "0219": 1, "0305": 2, "0320": 3, "0404": 4, "0419": 5,
                "0505": 6, "0520": 7, "0605": 8, "0621": 9, "0706": 10, "0722": 11,
                "0807": 12, "0822": 13, "0907": 14, "0922": 15, "1008": 16, "1023": 17,
                "1107": 18, "1122": 19, "1207": 20, "1221": 21, "0106": 22, "0120": 23
            ],
            "2025": [
                "0203": 0, "0218": 1, "0305": 2, "0320": 3, "0404": 4, "0420": 5,
                "0505": 6, "0521": 7, "0605": 8, "0621": 9, "0707": 10, "0722": 11,
                "0808": 12, "0823": 13, "0907": 14, "0923": 15, "1008": 16, "1023": 17,
                "1107": 18, "1122": 19, "1207": 20, "1221": 21, "0105": 22, "0120": 23
            ]
        ]
    }
    
    /// 获取指定日期的节气信息
    /// - Parameter date: 日期
    /// - Returns: 节气索引和名称的元组，如果不是节气则返回(-1, nil)
    public static func solarTermInfo(for date: Date) -> (index: Int, name: String?) {
        // 确保数据已初始化
        if solarTermsData.isEmpty {
            initialize()
        }
        
        let calendar = Calendar.current
        let year = calendar.component(.year, from: date)
        let formatter = DateFormatter()
        formatter.dateFormat = "MMdd"
        let dateString = formatter.string(from: date)
        
        // 检查当年是否有节气数据
        if let yearData = solarTermsData[String(year)],
           let termIndex = yearData[dateString] {
            return (termIndex, solarTermNames[termIndex])
        }
        
        // 检查前一年的最后几个节气（可能跨年）
        if let lastYearData = solarTermsData[String(year - 1)],
           let termIndex = lastYearData[dateString] {
            return (termIndex, solarTermNames[termIndex])
        }
        
        // 检查下一年的前几个节气（可能跨年）
        if let nextYearData = solarTermsData[String(year + 1)],
           let termIndex = nextYearData[dateString] {
            return (termIndex, solarTermNames[termIndex])
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
        // 确保数据已初始化
        if solarTermsData.isEmpty {
            initialize()
        }
        
        var terms: [String: Date] = [:]
        
        guard let yearData = solarTermsData[String(year)] else {
            return terms
        }
        
        let calendar = Calendar.current
        
        for (dateString, termIndex) in yearData {
            // 解析月日字符串
            let month = Int(dateString.prefix(2))!
            let day = Int(dateString.suffix(2))!
            
            // 创建日期
            if let date = calendar.date(from: DateComponents(year: year, month: month, day: day)) {
                let termName = solarTermNames[termIndex]
                terms[termName] = date
            }
        }
        
        return terms
    }
    
    /// 获取下一个节气的日期和名称
    /// - Parameter date: 当前日期
    /// - Returns: 下一个节气的日期和名称，如果没有找到返回nil
    public static func nextSolarTerm(after date: Date) -> (date: Date, name: String)? {
        let calendar = Calendar.current
        let year = calendar.component(.year, from: date)
        
        // 获取当年所有节气
        let allTerms = getAllSolarTerms(for: year)
        
        // 按日期排序
        let sortedTerms = allTerms.sorted { $0.value < $1.value }
        
        // 找到下一个节气
        for (name, termDate) in sortedTerms {
            if termDate > date {
                return (termDate, name)
            }
        }
        
        // 如果当年没有找到，检查下一年的第一个节气
        let nextYearTerms = getAllSolarTerms(for: year + 1)
        if let nextYearFirst = nextYearTerms.sorted(by: { $0.value < $1.value }).first {
            return (nextYearFirst.value, nextYearFirst.key)
        }
        
        return nil
    }
    
    /// 获取上一个节气的日期和名称
    /// - Parameter date: 当前日期
    /// - Returns: 上一个节气的日期和名称，如果没有找到返回nil
    public static func previousSolarTerm(before date: Date) -> (date: Date, name: String)? {
        let calendar = Calendar.current
        let year = calendar.component(.year, from: date)
        
        // 获取当年所有节气
        let allTerms = getAllSolarTerms(for: year)
        
        // 按日期排序
        let sortedTerms = allTerms.sorted { $0.value < $1.value }
        
        // 找到上一个节气
        for (name, termDate) in sortedTerms.reversed() {
            if termDate < date {
                return (termDate, name)
            }
        }
        
        // 如果当年没有找到，检查前一年的最后一个节气
        let prevYearTerms = getAllSolarTerms(for: year - 1)
        if let prevYearLast = prevYearTerms.sorted(by: { $0.value < $1.value }).last {
            return (prevYearLast.value, prevYearLast.key)
        }
        
        return nil
    }
}