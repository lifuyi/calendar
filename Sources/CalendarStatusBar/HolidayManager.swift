import Foundation

enum HolidayType: Int {
    case workday = 1
    case holiday = 2
}

final class HolidayManager {
    static let `default` = HolidayManager()
    
    private var defaultData: [String: [String: Int]] = [:]
    
    // 各年度节假日名称，键为放假第一天（调休假期可能早于节日当天，例如除夕）
    private let holidayNames: [String: [String: String]] = [
        "2025": [
            "0101": "元旦",
            "0128": "春节",
            "0404": "清明节",
            "0501": "劳动节",
            "0531": "端午节",
            "1001": "国庆节"
        ],
        "2026": [
            "0101": "元旦",
            "0215": "春节",
            "0404": "清明节",
            "0501": "劳动节",
            "0619": "端午节",
            "0925": "中秋节",
            "1001": "国庆节"
        ],
        "2027": [
            "0101": "元旦",
            "0205": "春节",
            "0403": "清明节",
            "0501": "劳动节",
            "0609": "端午节",
            "0915": "中秋节",
            "1001": "国庆节"
        ]
    ]
    
    private init() {
        if let data = loadHolidayData() {
            defaultData = data
        }
    }
    
    func typeOf(year: Int, monthDay: String) -> HolidayType? {
        let yearString = String(year)
        if let value = defaultData[yearString]?[monthDay], let type = HolidayType(rawValue: value) {
            return type
        }
        
        return nil
    }
    
    func nameOf(year: Int, monthDay: String) -> String? {
        return holidayNames[String(year)]?[monthDay]
    }
    
    private func loadHolidayData() -> [String: [String: Int]]? {
        // Get the resource URL from the main bundle
        guard let url = Bundle.main.url(forResource: "mainland-china", withExtension: "json") else {
            return nil
        }
        
        do {
            let data = try Data(contentsOf: url)
            guard let json = try JSONSerialization.jsonObject(with: data) as? [String: [String: Int]] else {
                return nil
            }
            return json
        } catch {
            return nil
        }
    }
}