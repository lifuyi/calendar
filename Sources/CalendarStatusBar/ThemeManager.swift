import SwiftUI
import Foundation

// 主题类型枚举
enum ThemeType: String, CaseIterable {
    case system = "System"
    case light = "Light"
    case dark = "Dark"
    case aurora = "Aurora"
    case sunset = "Sunset"
    case ocean = "Ocean"
    
    var displayName: String {
        switch self {
        case .system: return "系统默认"
        case .light: return "浅色"
        case .dark: return "深色"
        case .aurora: return "极光"
        case .sunset: return "日落"
        case .ocean: return "海洋"
        }
    }
}

// 主题结构体
struct Theme {
    let type: ThemeType
    let backgroundColor: Color
    let textColor: Color
    let secondaryTextColor: Color
    let accentColor: Color
    let gridBackgroundColor: Color
    let weekendColor: Color
    let holidayColor: Color
    let todayBackgroundColor: Color
    let todayTextColor: Color
    let workdayColor: Color
    let solarTermColor: Color
    
    // 预设主题
    static let light = Theme(
        type: .light,
        backgroundColor: Color.white,
        textColor: Color.black,
        secondaryTextColor: Color.gray,
        accentColor: Color.blue,
        gridBackgroundColor: Color.white,
        weekendColor: Color(red: 0.6, green: 0.4, blue: 0.2),
        holidayColor: Color.red,
        todayBackgroundColor: Color.blue.opacity(0.3),
        todayTextColor: Color.blue,
        workdayColor: Color.orange,
        solarTermColor: Color.blue
    )
    
    static let dark = Theme(
        type: .dark,
        backgroundColor: Color.black,
        textColor: Color.white,
        secondaryTextColor: Color.gray,
        accentColor: Color.blue,
        gridBackgroundColor: Color(red: 0.1, green: 0.1, blue: 0.1),
        weekendColor: Color(red: 0.7, green: 0.5, blue: 0.3),
        holidayColor: Color.red,
        todayBackgroundColor: Color.blue.opacity(0.3),
        todayTextColor: Color.white,
        workdayColor: Color.orange,
        solarTermColor: Color.blue
    )
    
    static let aurora = Theme(
        type: .aurora,
        backgroundColor: Color(red: 0.05, green: 0.15, blue: 0.25),
        textColor: Color.white,
        secondaryTextColor: Color(red: 0.7, green: 0.8, blue: 0.9),
        accentColor: Color(red: 0.2, green: 0.8, blue: 0.6),
        gridBackgroundColor: Color(red: 0.1, green: 0.2, blue: 0.3),
        weekendColor: Color(red: 0.8, green: 0.6, blue: 0.9),
        holidayColor: Color(red: 1.0, green: 0.4, blue: 0.4),
        todayBackgroundColor: Color(red: 0.3, green: 0.7, blue: 0.5).opacity(0.3),
        todayTextColor: Color.white,
        workdayColor: Color.orange,
        solarTermColor: Color(red: 0.4, green: 0.9, blue: 0.8)
    )
    
    static let sunset = Theme(
        type: .sunset,
        backgroundColor: Color(red: 0.2, green: 0.1, blue: 0.15),
        textColor: Color.white,
        secondaryTextColor: Color(red: 0.8, green: 0.7, blue: 0.7),
        accentColor: Color(red: 1.0, green: 0.5, blue: 0.3),
        gridBackgroundColor: Color(red: 0.25, green: 0.15, blue: 0.2),
        weekendColor: Color(red: 0.9, green: 0.6, blue: 0.5),
        holidayColor: Color(red: 1.0, green: 0.3, blue: 0.3),
        todayBackgroundColor: Color(red: 1.0, green: 0.6, blue: 0.4).opacity(0.3),
        todayTextColor: Color.white,
        workdayColor: Color.orange,
        solarTermColor: Color(red: 1.0, green: 0.7, blue: 0.5)
    )
    
    static let ocean = Theme(
        type: .ocean,
        backgroundColor: Color(red: 0.05, green: 0.2, blue: 0.3),
        textColor: Color.white,
        secondaryTextColor: Color(red: 0.6, green: 0.8, blue: 0.9),
        accentColor: Color(red: 0.2, green: 0.6, blue: 0.9),
        gridBackgroundColor: Color(red: 0.1, green: 0.25, blue: 0.35),
        weekendColor: Color(red: 0.5, green: 0.8, blue: 0.9),
        holidayColor: Color(red: 1.0, green: 0.4, blue: 0.4),
        todayBackgroundColor: Color(red: 0.3, green: 0.7, blue: 1.0).opacity(0.3),
        todayTextColor: Color.white,
        workdayColor: Color.orange,
        solarTermColor: Color(red: 0.5, green: 0.9, blue: 1.0)
    )
}

class ThemeManager: ObservableObject {
    static let shared = ThemeManager()
    
    @Published var currentTheme: Theme {
        didSet {
            UserDefaults.standard.set(currentTheme.type.rawValue, forKey: "selectedTheme")
        }
    }
    
    private init() {
        // 从 UserDefaults 加载保存的主题，如果没有则使用系统默认
        let savedThemeType = UserDefaults.standard.string(forKey: "selectedTheme") ?? ThemeType.system.rawValue
        let themeType = ThemeType(rawValue: savedThemeType) ?? .system
        
        if themeType == .system {
            // 根据系统外观设置主题
            #if os(macOS)
            let isDark = NSApp.effectiveAppearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
            currentTheme = isDark ? .dark : .light
            #else
            currentTheme = .light
            #endif
        } else {
            currentTheme = ThemeManager.theme(for: themeType)
        }
    }
    
    static func theme(for type: ThemeType) -> Theme {
        switch type {
        case .light:
            return Theme.light
        case .dark:
            return Theme.dark
        case .aurora:
            return Theme.aurora
        case .sunset:
            return Theme.sunset
        case .ocean:
            return Theme.ocean
        case .system:
            // 系统主题在运行时根据系统外观决定
            #if os(macOS)
            let isDark = NSApp.effectiveAppearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
            return isDark ? .dark : .light
            #else
            return .light
            #endif
        }
    }
    
    func setTheme(_ type: ThemeType) {
        if type == .system {
            // 根据系统外观设置主题
            #if os(macOS)
            let isDark = NSApp.effectiveAppearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
            currentTheme = isDark ? .dark : .light
            #else
            currentTheme = .light
            #endif
        } else {
            currentTheme = ThemeManager.theme(for: type)
        }
    }
}