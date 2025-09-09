import Foundation

enum HolidayType: Int {
    case workday = 1
    case holiday = 2
}

final class HolidayManager {
    static let `default` = HolidayManager()
    
    private var defaultData: [String: [String: Int]] = [:]
    
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