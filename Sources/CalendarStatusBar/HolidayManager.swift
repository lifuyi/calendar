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
        // Try to get the resource URL
        var url: URL?
        
        // First try Bundle.module (for Swift packages)
        #if canImport(SwiftUI)
        url = Bundle.module.url(forResource: "mainland-china", withExtension: "json")
        #endif
        
        // If that doesn't work, try the main bundle
        if url == nil {
            url = Bundle.main.url(forResource: "mainland-china", withExtension: "json")
        }
        
        guard let url = url else {
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