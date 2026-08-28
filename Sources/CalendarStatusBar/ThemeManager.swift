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
    case forest = "Forest"
    case cherryBlossom = "CherryBlossom"
    case lavender = "Lavender"
    case neon = "Neon"
    case autumn = "Autumn"
    case tropical = "Tropical"
    case matcha = "Matcha"
    case roseGold = "RoseGold"
    case arctic = "Arctic"
    
    var displayName: String {
        switch self {
        case .system: return "系统默认"
        case .light: return "浅色"
        case .dark: return "深色"
        case .aurora: return "极光"
        case .sunset: return "日落"
        case .ocean: return "海洋"
        case .forest: return "森林"
        case .cherryBlossom: return "樱花"
        case .lavender: return "薰衣草"
        case .neon: return "霓虹"
        case .autumn: return "秋日"
        case .tropical: return "热带"
        case .matcha: return "抹茶"
        case .roseGold: return "玫瑰金"
        case .arctic: return "极地冰川"
        }
    }
}

// 字体大小选项
enum FontSize: String, CaseIterable {
    case small = "Small"
    case medium = "Medium"
    case large = "Large"
    case extraLarge = "ExtraLarge"
    
    var displayName: String {
        switch self {
        case .small: return "小"
        case .medium: return "中"
        case .large: return "大"
        case .extraLarge: return "特大"
        }
    }
    
    var calendarFontSize: CGFloat {
        switch self {
        case .small: return 11
        case .medium: return 13
        case .large: return 15
        case .extraLarge: return 17
        }
    }
    
    var headerFontSize: CGFloat {
        switch self {
        case .small: return 14
        case .medium: return 16
        case .large: return 18
        case .extraLarge: return 20
        }
    }
    
    var lunarFontSize: CGFloat {
        switch self {
        case .small: return 8
        case .medium: return 9
        case .large: return 10
        case .extraLarge: return 11
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
    
    // 字体设置
    let fontSize: FontSize
    
    // 自定义颜色选项
    let customAccentColor: Color?
    let customTodayColor: Color?
    
    // MARK: - 预设主题
    
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
        solarTermColor: Color.blue,


        fontSize: .medium,
        customAccentColor: nil,
        customTodayColor: nil
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
        solarTermColor: Color.blue,


        fontSize: .medium,
        customAccentColor: nil,
        customTodayColor: nil
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
        solarTermColor: Color(red: 0.4, green: 0.9, blue: 0.8),


        fontSize: .medium,
        customAccentColor: nil,
        customTodayColor: nil
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
        solarTermColor: Color(red: 1.0, green: 0.7, blue: 0.5),


        fontSize: .medium,
        customAccentColor: nil,
        customTodayColor: nil
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
        solarTermColor: Color(red: 0.5, green: 0.9, blue: 1.0),


        fontSize: .medium,
        customAccentColor: nil,
        customTodayColor: nil
    )
    
    static let forest = Theme(
        type: .forest,
        backgroundColor: Color(red: 0.1, green: 0.2, blue: 0.1),
        textColor: Color(red: 0.9, green: 0.95, blue: 0.9),
        secondaryTextColor: Color(red: 0.7, green: 0.8, blue: 0.7),
        accentColor: Color(red: 0.4, green: 0.8, blue: 0.4),
        gridBackgroundColor: Color(red: 0.15, green: 0.25, blue: 0.15),
        weekendColor: Color(red: 0.6, green: 0.9, blue: 0.6),
        holidayColor: Color(red: 1.0, green: 0.6, blue: 0.3),
        todayBackgroundColor: Color(red: 0.3, green: 0.7, blue: 0.3).opacity(0.4),
        todayTextColor: Color.white,
        workdayColor: Color(red: 0.9, green: 0.7, blue: 0.3),
        solarTermColor: Color(red: 0.5, green: 0.9, blue: 0.5),


        fontSize: .medium,
        customAccentColor: nil,
        customTodayColor: nil
    )
    
    static let cherryBlossom = Theme(
        type: .cherryBlossom,
        backgroundColor: Color(red: 0.98, green: 0.94, blue: 0.96),
        textColor: Color(red: 0.3, green: 0.2, blue: 0.3),
        secondaryTextColor: Color(red: 0.6, green: 0.5, blue: 0.6),
        accentColor: Color(red: 0.9, green: 0.4, blue: 0.7),
        gridBackgroundColor: Color(red: 0.95, green: 0.9, blue: 0.93),
        weekendColor: Color(red: 0.8, green: 0.3, blue: 0.6),
        holidayColor: Color(red: 0.9, green: 0.2, blue: 0.5),
        todayBackgroundColor: Color(red: 0.9, green: 0.6, blue: 0.8).opacity(0.3),
        todayTextColor: Color(red: 0.6, green: 0.2, blue: 0.4),
        workdayColor: Color(red: 0.8, green: 0.5, blue: 0.2),
        solarTermColor: Color(red: 0.7, green: 0.3, blue: 0.6),


        fontSize: .medium,
        customAccentColor: nil,
        customTodayColor: nil
    )
    
    static let lavender = Theme(
        type: .lavender,
        backgroundColor: Color(red: 0.15, green: 0.1, blue: 0.25),
        textColor: Color(red: 0.9, green: 0.85, blue: 0.95),
        secondaryTextColor: Color(red: 0.7, green: 0.65, blue: 0.8),
        accentColor: Color(red: 0.7, green: 0.5, blue: 0.9),
        gridBackgroundColor: Color(red: 0.2, green: 0.15, blue: 0.3),
        weekendColor: Color(red: 0.8, green: 0.6, blue: 0.9),
        holidayColor: Color(red: 0.9, green: 0.4, blue: 0.7),
        todayBackgroundColor: Color(red: 0.6, green: 0.4, blue: 0.8).opacity(0.4),
        todayTextColor: Color.white,
        workdayColor: Color(red: 0.9, green: 0.6, blue: 0.4),
        solarTermColor: Color(red: 0.8, green: 0.6, blue: 0.9),


        fontSize: .medium,
        customAccentColor: nil,
        customTodayColor: nil
    )
    
    static let neon = Theme(
        type: .neon,
        backgroundColor: Color(red: 0.05, green: 0.05, blue: 0.1),
        textColor: Color(red: 0.0, green: 1.0, blue: 0.8),
        secondaryTextColor: Color(red: 0.6, green: 0.8, blue: 0.9),
        accentColor: Color(red: 1.0, green: 0.0, blue: 0.8),
        gridBackgroundColor: Color(red: 0.1, green: 0.1, blue: 0.15),
        weekendColor: Color(red: 0.8, green: 0.0, blue: 1.0),
        holidayColor: Color(red: 1.0, green: 0.2, blue: 0.4),
        todayBackgroundColor: Color(red: 0.0, green: 0.8, blue: 1.0).opacity(0.3),
        todayTextColor: Color(red: 0.0, green: 0.0, blue: 0.0),
        workdayColor: Color(red: 1.0, green: 0.8, blue: 0.0),
        solarTermColor: Color(red: 0.4, green: 1.0, blue: 0.6),


        fontSize: .medium,
        customAccentColor: nil,
        customTodayColor: nil
    )
    
    static let autumn = Theme(
        type: .autumn,
        backgroundColor: Color(red: 0.2, green: 0.15, blue: 0.1),
        textColor: Color(red: 0.95, green: 0.9, blue: 0.8),
        secondaryTextColor: Color(red: 0.8, green: 0.7, blue: 0.6),
        accentColor: Color(red: 0.9, green: 0.6, blue: 0.2),
        gridBackgroundColor: Color(red: 0.25, green: 0.2, blue: 0.15),
        weekendColor: Color(red: 0.9, green: 0.5, blue: 0.3),
        holidayColor: Color(red: 0.9, green: 0.3, blue: 0.2),
        todayBackgroundColor: Color(red: 0.8, green: 0.5, blue: 0.2).opacity(0.4),
        todayTextColor: Color.white,
        workdayColor: Color(red: 0.8, green: 0.7, blue: 0.3),
        solarTermColor: Color(red: 0.9, green: 0.7, blue: 0.4),


        fontSize: .medium,
        customAccentColor: nil,
        customTodayColor: nil
    )
    
    static let tropical = Theme(
        type: .tropical,
        backgroundColor: Color(red: 0.0, green: 0.3, blue: 0.2),
        textColor: Color(red: 0.95, green: 0.98, blue: 0.9),
        secondaryTextColor: Color(red: 0.7, green: 0.9, blue: 0.8),
        accentColor: Color(red: 1.0, green: 0.8, blue: 0.0),
        gridBackgroundColor: Color(red: 0.05, green: 0.35, blue: 0.25),
        weekendColor: Color(red: 0.9, green: 0.7, blue: 0.2),
        holidayColor: Color(red: 1.0, green: 0.4, blue: 0.3),
        todayBackgroundColor: Color(red: 0.8, green: 0.9, blue: 0.0).opacity(0.3),
        todayTextColor: Color(red: 0.2, green: 0.4, blue: 0.1),
        workdayColor: Color(red: 0.9, green: 0.5, blue: 0.1),
        solarTermColor: Color(red: 0.6, green: 0.9, blue: 0.3),


        fontSize: .medium,
        customAccentColor: nil,
        customTodayColor: nil
    )
    
    static let matcha = Theme(
        type: .matcha,
        backgroundColor: Color(red: 0.92, green: 0.95, blue: 0.88),
        textColor: Color(red: 0.2, green: 0.3, blue: 0.15),
        secondaryTextColor: Color(red: 0.45, green: 0.55, blue: 0.4),
        accentColor: Color(red: 0.45, green: 0.65, blue: 0.3),
        gridBackgroundColor: Color(red: 0.88, green: 0.92, blue: 0.82),
        weekendColor: Color(red: 0.6, green: 0.5, blue: 0.2),
        holidayColor: Color(red: 0.85, green: 0.3, blue: 0.25),
        todayBackgroundColor: Color(red: 0.5, green: 0.7, blue: 0.35).opacity(0.3),
        todayTextColor: Color(red: 0.25, green: 0.4, blue: 0.15),
        workdayColor: Color(red: 0.7, green: 0.55, blue: 0.2),
        solarTermColor: Color(red: 0.4, green: 0.6, blue: 0.3),


        fontSize: .medium,
        customAccentColor: nil,
        customTodayColor: nil
    )
    
    static let roseGold = Theme(
        type: .roseGold,
        backgroundColor: Color(red: 0.96, green: 0.93, blue: 0.93),
        textColor: Color(red: 0.35, green: 0.2, blue: 0.25),
        secondaryTextColor: Color(red: 0.6, green: 0.45, blue: 0.5),
        accentColor: Color(red: 0.75, green: 0.4, blue: 0.5),
        gridBackgroundColor: Color(red: 0.93, green: 0.88, blue: 0.88),
        weekendColor: Color(red: 0.7, green: 0.35, blue: 0.45),
        holidayColor: Color(red: 0.85, green: 0.25, blue: 0.3),
        todayBackgroundColor: Color(red: 0.8, green: 0.5, blue: 0.55).opacity(0.3),
        todayTextColor: Color(red: 0.5, green: 0.2, blue: 0.3),
        workdayColor: Color(red: 0.75, green: 0.55, blue: 0.2),
        solarTermColor: Color(red: 0.7, green: 0.4, blue: 0.55),


        fontSize: .medium,
        customAccentColor: nil,
        customTodayColor: nil
    )
    
    static let arctic = Theme(
        type: .arctic,
        backgroundColor: Color(red: 0.93, green: 0.96, blue: 0.99),
        textColor: Color(red: 0.15, green: 0.25, blue: 0.4),
        secondaryTextColor: Color(red: 0.4, green: 0.55, blue: 0.7),
        accentColor: Color(red: 0.2, green: 0.55, blue: 0.85),
        gridBackgroundColor: Color(red: 0.88, green: 0.93, blue: 0.97),
        weekendColor: Color(red: 0.3, green: 0.5, blue: 0.75),
        holidayColor: Color(red: 0.9, green: 0.3, blue: 0.35),
        todayBackgroundColor: Color(red: 0.3, green: 0.65, blue: 0.9).opacity(0.3),
        todayTextColor: Color(red: 0.1, green: 0.35, blue: 0.65),
        workdayColor: Color(red: 0.6, green: 0.5, blue: 0.2),
        solarTermColor: Color(red: 0.25, green: 0.6, blue: 0.8),


        fontSize: .medium,
        customAccentColor: nil,
        customTodayColor: nil
    )
    
    // MARK: - Theme Copy Helpers
    
    func withFontSize(_ size: FontSize) -> Theme {
        Theme(type: type, backgroundColor: backgroundColor, textColor: textColor, secondaryTextColor: secondaryTextColor, accentColor: accentColor, gridBackgroundColor: gridBackgroundColor, weekendColor: weekendColor, holidayColor: holidayColor, todayBackgroundColor: todayBackgroundColor, todayTextColor: todayTextColor, workdayColor: workdayColor, solarTermColor: solarTermColor, fontSize: size, customAccentColor: customAccentColor, customTodayColor: customTodayColor)
    }
    
    func withCustomAccentColor(_ color: Color?) -> Theme {
        Theme(type: type, backgroundColor: backgroundColor, textColor: textColor, secondaryTextColor: secondaryTextColor, accentColor: accentColor, gridBackgroundColor: gridBackgroundColor, weekendColor: weekendColor, holidayColor: holidayColor, todayBackgroundColor: todayBackgroundColor, todayTextColor: todayTextColor, workdayColor: workdayColor, solarTermColor: solarTermColor, fontSize: fontSize, customAccentColor: color, customTodayColor: customTodayColor)
    }
    
    func withCustomTodayColor(_ color: Color?) -> Theme {
        Theme(type: type, backgroundColor: backgroundColor, textColor: textColor, secondaryTextColor: secondaryTextColor, accentColor: accentColor, gridBackgroundColor: gridBackgroundColor, weekendColor: weekendColor, holidayColor: holidayColor, todayBackgroundColor: todayBackgroundColor, todayTextColor: todayTextColor, workdayColor: workdayColor, solarTermColor: solarTermColor, fontSize: fontSize, customAccentColor: customAccentColor, customTodayColor: color)
    }
}

// MARK: - Theme Factory

extension Theme {
    static func theme(for type: ThemeType) -> Theme {
        switch type {
        case .light: return Theme.light
        case .dark: return Theme.dark
        case .aurora: return Theme.aurora
        case .sunset: return Theme.sunset
        case .ocean: return Theme.ocean
        case .forest: return Theme.forest
        case .cherryBlossom: return Theme.cherryBlossom
        case .lavender: return Theme.lavender
        case .neon: return Theme.neon
        case .autumn: return Theme.autumn
        case .tropical: return Theme.tropical
        case .matcha: return Theme.matcha
        case .roseGold: return Theme.roseGold
        case .arctic: return Theme.arctic
        case .system:
            #if os(macOS)
            let isDark = NSApp.effectiveAppearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
            return isDark ? .dark : .light
            #else
            return .light
            #endif
        }
    }
}

// MARK: - Theme Manager

class ThemeManager: ObservableObject {
    static let shared = ThemeManager()
    
    @Published var currentTheme: Theme {
        didSet {
            UserDefaults.standard.set(currentTheme.type.rawValue, forKey: "selectedTheme")
            UserDefaults.standard.set(currentTheme.fontSize.rawValue, forKey: "fontSize")
            
            if let customAccent = currentTheme.customAccentColor {
                if let colorData = try? NSKeyedArchiver.archivedData(withRootObject: NSColor(customAccent), requiringSecureCoding: false) {
                    UserDefaults.standard.set(colorData, forKey: "customAccentColor")
                }
            } else {
                UserDefaults.standard.removeObject(forKey: "customAccentColor")
            }
            
            if let customToday = currentTheme.customTodayColor {
                if let colorData = try? NSKeyedArchiver.archivedData(withRootObject: NSColor(customToday), requiringSecureCoding: false) {
                    UserDefaults.standard.set(colorData, forKey: "customTodayColor")
                }
            } else {
                UserDefaults.standard.removeObject(forKey: "customTodayColor")
            }
        }
    }
    
    private init() {
        let savedThemeType = UserDefaults.standard.string(forKey: "selectedTheme") ?? ThemeType.system.rawValue
        let themeType = ThemeType(rawValue: savedThemeType) ?? .system
        
        var baseTheme: Theme
        if themeType == .system {
            #if os(macOS)
            let isDark = NSApp.effectiveAppearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
            baseTheme = isDark ? Theme.dark : Theme.light
            #else
            baseTheme = Theme.light
            #endif
        } else {
            baseTheme = Theme.theme(for: themeType)
        }
        
        currentTheme = baseTheme
    }
    
    func setTheme(_ type: ThemeType) {
        var baseTheme: Theme
        if type == .system {
            #if os(macOS)
            let isDark = NSApp.effectiveAppearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
            baseTheme = isDark ? Theme.dark : Theme.light
            #else
            baseTheme = Theme.light
            #endif
        } else {
            baseTheme = Theme.theme(for: type)
        }
        
        currentTheme = baseTheme
    }
    
    func setFontSize(_ fontSize: FontSize) {
        currentTheme = currentTheme.withFontSize(fontSize)
    }
    
    func setCustomAccentColor(_ color: Color?) {
        currentTheme = currentTheme.withCustomAccentColor(color)
    }
    
    func setCustomTodayColor(_ color: Color?) {
        currentTheme = currentTheme.withCustomTodayColor(color)
    }
    
    var effectiveAccentColor: Color {
        return currentTheme.customAccentColor ?? currentTheme.accentColor
    }
    
    var effectiveTodayColor: Color {
        return currentTheme.customTodayColor ?? currentTheme.todayBackgroundColor
    }
}
