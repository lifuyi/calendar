import Foundation

enum HolidayType: Int {
    case workday = 1
    case holiday = 2
}

final class HolidayManager {
    static let `default` = HolidayManager()
    
    private var defaultData: [String: [String: Int]] = [:]
    
    private init() {
        print("Initializing HolidayManager...")
        if let data = loadHolidayData() {
            defaultData = data
            print("Successfully loaded holiday data with \(data.count) years")
        } else {
            print("Failed to load default holidays")
        }
    }
    
    func typeOf(year: Int, monthDay: String) -> HolidayType? {
        let yearString = String(year)
        if let value = defaultData[yearString]?[monthDay], let type = HolidayType(rawValue: value) {
            print("Found holiday data for \(year)-\(monthDay): \(type)")
            return type
        }
        
        return nil
    }
    
    // MARK: - Private
    
    private func loadHolidayData() -> [String: [String: Int]]? {
        print("Attempting to load holiday data...")
        
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
            print("Failed to find holiday data file in bundle")
            return nil
        }
        
        print("Found holiday data file at: \(url.path)")
        
        do {
            let data = try Data(contentsOf: url)
            print("Successfully read \(data.count) bytes from holiday data file")
            guard let json = try JSONSerialization.jsonObject(with: data) as? [String: [String: Int]] else {
                print("Failed to decode holiday data as dictionary")
                return nil
            }
            print("Successfully decoded holiday data with \(json.count) years")
            return json
        } catch {
            print("Failed to read or parse holiday data: \(error)")
            return nil
        }
    }
}