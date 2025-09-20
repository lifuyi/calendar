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

// 毛玻璃材质选项
enum BlurMaterial: String, CaseIterable {
    case light = "Light"
    case dark = "Dark"
    case ultraThin = "UltraThin"
    case thin = "Thin"
    case regular = "Regular"
    case thick = "Thick"
    case hudWindow = "HudWindow"
    
    var displayName: String {
        switch self {
        case .light: return "浅色"
        case .dark: return "深色"
        case .ultraThin: return "超薄"
        case .thin: return "薄"
        case .regular: return "标准"
        case .thick: return "厚"
        case .hudWindow: return "HUD窗口"
        }
    }
    
    #if canImport(AppKit)
    var nsMaterial: NSVisualEffectView.Material {
        switch self {
        case .light: return .underWindowBackground
        case .dark: return .fullScreenUI
        case .ultraThin: return .underWindowBackground
        case .thin: return .windowBackground
        case .regular: return .menu
        case .thick: return .popover
        case .hudWindow: return .hudWindow
        }
    }
    #endif
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
    
    // 毛玻璃效果属性
    let blurEnabled: Bool
    let blurOpacity: Double
    let blurMaterial: BlurMaterial
    let blurBackground: Bool  // 是否虚化背景层（true）而不是前景层（false）
    
    // 字体设置
    let fontSize: FontSize
    
    // 自定义颜色选项
    let customAccentColor: Color?
    let customTodayColor: Color?
    
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
        solarTermColor: Color.blue,
        blurEnabled: true,
        blurOpacity: 0.7,
        blurMaterial: .light,
        blurBackground: false,
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
        blurEnabled: true,
        blurOpacity: 0.85,
        blurMaterial: .dark,
        blurBackground: true,
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
        blurEnabled: true,
        blurOpacity: 0.9,
        blurMaterial: .hudWindow,
        blurBackground: true,
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
        blurEnabled: true,
        blurOpacity: 0.9,
        blurMaterial: .thick,
        blurBackground: true,
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
        blurEnabled: true,
        blurOpacity: 0.75,
        blurMaterial: .ultraThin,
        blurBackground: true,
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
        blurEnabled: true,
        blurOpacity: 0.9,
        blurMaterial: .regular,
        blurBackground: true,
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
        blurEnabled: true,
        blurOpacity: 0.75,
        blurMaterial: .light,
        blurBackground: false,
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
        blurEnabled: true,
        blurOpacity: 0.8,
        blurMaterial: .thin,
        blurBackground: true,
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
        blurEnabled: true,
        blurOpacity: 0.85,
        blurMaterial: .hudWindow,
        blurBackground: true,
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
        blurEnabled: true,
        blurOpacity: 0.9,
        blurMaterial: .thick,
        blurBackground: true,
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
        blurEnabled: true,
        blurOpacity: 0.9,
        blurMaterial: .regular,
        blurBackground: true,
        fontSize: .medium,
        customAccentColor: nil,
        customTodayColor: nil
    )
}

class ThemeManager: ObservableObject {
    static let shared = ThemeManager()
    
    @Published var currentTheme: Theme {
        didSet {
            UserDefaults.standard.set(currentTheme.type.rawValue, forKey: "selectedTheme")
            UserDefaults.standard.set(currentTheme.blurEnabled, forKey: "blurEnabled")
            UserDefaults.standard.set(currentTheme.blurOpacity, forKey: "blurOpacity")
            UserDefaults.standard.set(currentTheme.blurMaterial.rawValue, forKey: "blurMaterial")
            UserDefaults.standard.set(currentTheme.blurBackground, forKey: "blurBackground")
            UserDefaults.standard.set(currentTheme.fontSize.rawValue, forKey: "fontSize")
            
            // Save custom colors if they exist
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
        // 从 UserDefaults 加载保存的主题，如果没有则使用系统默认
        let savedThemeType = UserDefaults.standard.string(forKey: "selectedTheme") ?? ThemeType.system.rawValue
        let themeType = ThemeType(rawValue: savedThemeType) ?? .system
        
        // 加载毛玻璃效果设置
        let blurEnabled = UserDefaults.standard.bool(forKey: "blurEnabled")
        let blurOpacity = UserDefaults.standard.double(forKey: "blurOpacity")
        let blurBackground = UserDefaults.standard.object(forKey: "blurBackground") != nil ? 
            UserDefaults.standard.bool(forKey: "blurBackground") : true
        
        if themeType == .system {
            // 根据系统外观设置主题
            #if os(macOS)
            let isDark = NSApp.effectiveAppearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
            var theme = isDark ? Theme.dark : Theme.light
            // 更新主题以包含毛玻璃效果设置
            theme = Theme(
                type: theme.type,
                backgroundColor: theme.backgroundColor,
                textColor: theme.textColor,
                secondaryTextColor: theme.secondaryTextColor,
                accentColor: theme.accentColor,
                gridBackgroundColor: theme.gridBackgroundColor,
                weekendColor: theme.weekendColor,
                holidayColor: theme.holidayColor,
                todayBackgroundColor: theme.todayBackgroundColor,
                todayTextColor: theme.todayTextColor,
                workdayColor: theme.workdayColor,
                solarTermColor: theme.solarTermColor,
                blurEnabled: blurEnabled,
                blurOpacity: blurOpacity > 0 ? blurOpacity : 0.5,
                blurMaterial: theme.blurMaterial,
                blurBackground: theme.blurBackground,
                fontSize: theme.fontSize,
                customAccentColor: theme.customAccentColor,
                customTodayColor: theme.customTodayColor
            )
            currentTheme = theme
            #else
            var theme = Theme.light
            // 更新主题以包含毛玻璃效果设置
            theme = Theme(
                type: theme.type,
                backgroundColor: theme.backgroundColor,
                textColor: theme.textColor,
                secondaryTextColor: theme.secondaryTextColor,
                accentColor: theme.accentColor,
                gridBackgroundColor: theme.gridBackgroundColor,
                weekendColor: theme.weekendColor,
                holidayColor: theme.holidayColor,
                todayBackgroundColor: theme.todayBackgroundColor,
                todayTextColor: theme.todayTextColor,
                workdayColor: theme.workdayColor,
                solarTermColor: theme.solarTermColor,
                blurEnabled: blurEnabled,
                blurOpacity: blurOpacity > 0 ? blurOpacity : 0.5,
                blurMaterial: theme.blurMaterial,
                blurBackground: theme.blurBackground,
                fontSize: theme.fontSize,
                customAccentColor: theme.customAccentColor,
                customTodayColor: theme.customTodayColor
            )
            currentTheme = theme
            #endif
        } else {
            var theme = ThemeManager.theme(for: themeType)
            // 更新主题以包含毛玻璃效果设置
            theme = Theme(
                type: theme.type,
                backgroundColor: theme.backgroundColor,
                textColor: theme.textColor,
                secondaryTextColor: theme.secondaryTextColor,
                accentColor: theme.accentColor,
                gridBackgroundColor: theme.gridBackgroundColor,
                weekendColor: theme.weekendColor,
                holidayColor: theme.holidayColor,
                todayBackgroundColor: theme.todayBackgroundColor,
                todayTextColor: theme.todayTextColor,
                workdayColor: theme.workdayColor,
                solarTermColor: theme.solarTermColor,
                blurEnabled: blurEnabled,
                blurOpacity: blurOpacity > 0 ? blurOpacity : 0.5,
                blurMaterial: theme.blurMaterial,
                blurBackground: theme.blurBackground,
                fontSize: theme.fontSize,
                customAccentColor: theme.customAccentColor,
                customTodayColor: theme.customTodayColor
            )
            currentTheme = theme
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
        case .forest:
            return Theme.forest
        case .cherryBlossom:
            return Theme.cherryBlossom
        case .lavender:
            return Theme.lavender
        case .neon:
            return Theme.neon
        case .autumn:
            return Theme.autumn
        case .tropical:
            return Theme.tropical
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
            var theme = isDark ? Theme.dark : Theme.light
            // 更新主题以包含毛玻璃效果设置
            theme = Theme(
                type: theme.type,
                backgroundColor: theme.backgroundColor,
                textColor: theme.textColor,
                secondaryTextColor: theme.secondaryTextColor,
                accentColor: theme.accentColor,
                gridBackgroundColor: theme.gridBackgroundColor,
                weekendColor: theme.weekendColor,
                holidayColor: theme.holidayColor,
                todayBackgroundColor: theme.todayBackgroundColor,
                todayTextColor: theme.todayTextColor,
                workdayColor: theme.workdayColor,
                solarTermColor: theme.solarTermColor,
                blurEnabled: currentTheme.blurEnabled,
                blurOpacity: currentTheme.blurOpacity,
                blurMaterial: theme.blurMaterial,
                blurBackground: theme.blurBackground,
                fontSize: theme.fontSize,
                customAccentColor: theme.customAccentColor,
                customTodayColor: theme.customTodayColor
            )
            currentTheme = theme
            #else
            var theme = Theme.light
            // 更新主题以包含毛玻璃效果设置
            theme = Theme(
                type: theme.type,
                backgroundColor: theme.backgroundColor,
                textColor: theme.textColor,
                secondaryTextColor: theme.secondaryTextColor,
                accentColor: theme.accentColor,
                gridBackgroundColor: theme.gridBackgroundColor,
                weekendColor: theme.weekendColor,
                holidayColor: theme.holidayColor,
                todayBackgroundColor: theme.todayBackgroundColor,
                todayTextColor: theme.todayTextColor,
                workdayColor: theme.workdayColor,
                solarTermColor: theme.solarTermColor,
                blurEnabled: currentTheme.blurEnabled,
                blurOpacity: currentTheme.blurOpacity,
                blurMaterial: theme.blurMaterial,
                blurBackground: theme.blurBackground,
                fontSize: theme.fontSize,
                customAccentColor: theme.customAccentColor,
                customTodayColor: theme.customTodayColor
            )
            currentTheme = theme
            #endif
        } else {
            var theme = ThemeManager.theme(for: type)
            // 更新主题以包含毛玻璃效果设置
            theme = Theme(
                type: theme.type,
                backgroundColor: theme.backgroundColor,
                textColor: theme.textColor,
                secondaryTextColor: theme.secondaryTextColor,
                accentColor: theme.accentColor,
                gridBackgroundColor: theme.gridBackgroundColor,
                weekendColor: theme.weekendColor,
                holidayColor: theme.holidayColor,
                todayBackgroundColor: theme.todayBackgroundColor,
                todayTextColor: theme.todayTextColor,
                workdayColor: theme.workdayColor,
                solarTermColor: theme.solarTermColor,
                blurEnabled: currentTheme.blurEnabled,
                blurOpacity: currentTheme.blurOpacity,
                blurMaterial: theme.blurMaterial,
                blurBackground: theme.blurBackground,
                fontSize: theme.fontSize,
                customAccentColor: theme.customAccentColor,
                customTodayColor: theme.customTodayColor
            )
            currentTheme = theme
        }
    }
    
    /// 设置毛玻璃效果
    func setBlurEffect(enabled: Bool, opacity: Double) {
        let theme = Theme(
            type: currentTheme.type,
            backgroundColor: currentTheme.backgroundColor,
            textColor: currentTheme.textColor,
            secondaryTextColor: currentTheme.secondaryTextColor,
            accentColor: currentTheme.accentColor,
            gridBackgroundColor: currentTheme.gridBackgroundColor,
            weekendColor: currentTheme.weekendColor,
            holidayColor: currentTheme.holidayColor,
            todayBackgroundColor: currentTheme.todayBackgroundColor,
            todayTextColor: currentTheme.todayTextColor,
            workdayColor: currentTheme.workdayColor,
            solarTermColor: currentTheme.solarTermColor,
            blurEnabled: enabled,
            blurOpacity: opacity,
            blurMaterial: currentTheme.blurMaterial,
            blurBackground: currentTheme.blurBackground,
            fontSize: currentTheme.fontSize,
            customAccentColor: currentTheme.customAccentColor,
            customTodayColor: currentTheme.customTodayColor
        )
        currentTheme = theme
    }
    
    /// 设置毛玻璃材质
    func setBlurMaterial(_ material: BlurMaterial) {
        let theme = Theme(
            type: currentTheme.type,
            backgroundColor: currentTheme.backgroundColor,
            textColor: currentTheme.textColor,
            secondaryTextColor: currentTheme.secondaryTextColor,
            accentColor: currentTheme.accentColor,
            gridBackgroundColor: currentTheme.gridBackgroundColor,
            weekendColor: currentTheme.weekendColor,
            holidayColor: currentTheme.holidayColor,
            todayBackgroundColor: currentTheme.todayBackgroundColor,
            todayTextColor: currentTheme.todayTextColor,
            workdayColor: currentTheme.workdayColor,
            solarTermColor: currentTheme.solarTermColor,
            blurEnabled: currentTheme.blurEnabled,
            blurOpacity: currentTheme.blurOpacity,
            blurMaterial: material,
            blurBackground: currentTheme.blurBackground,
            fontSize: currentTheme.fontSize,
            customAccentColor: currentTheme.customAccentColor,
            customTodayColor: currentTheme.customTodayColor
        )
        currentTheme = theme
    }
    
    /// 设置虚化方向（虚化背景层还是前景层）
    func setBlurBackground(_ blurBackground: Bool) {
        let theme = Theme(
            type: currentTheme.type,
            backgroundColor: currentTheme.backgroundColor,
            textColor: currentTheme.textColor,
            secondaryTextColor: currentTheme.secondaryTextColor,
            accentColor: currentTheme.accentColor,
            gridBackgroundColor: currentTheme.gridBackgroundColor,
            weekendColor: currentTheme.weekendColor,
            holidayColor: currentTheme.holidayColor,
            todayBackgroundColor: currentTheme.todayBackgroundColor,
            todayTextColor: currentTheme.todayTextColor,
            workdayColor: currentTheme.workdayColor,
            solarTermColor: currentTheme.solarTermColor,
            blurEnabled: currentTheme.blurEnabled,
            blurOpacity: currentTheme.blurOpacity,
            blurMaterial: currentTheme.blurMaterial,
            blurBackground: blurBackground,
            fontSize: currentTheme.fontSize,
            customAccentColor: currentTheme.customAccentColor,
            customTodayColor: currentTheme.customTodayColor
        )
        currentTheme = theme
    }
    
    /// 设置字体大小
    func setFontSize(_ fontSize: FontSize) {
        let theme = Theme(
            type: currentTheme.type,
            backgroundColor: currentTheme.backgroundColor,
            textColor: currentTheme.textColor,
            secondaryTextColor: currentTheme.secondaryTextColor,
            accentColor: currentTheme.accentColor,
            gridBackgroundColor: currentTheme.gridBackgroundColor,
            weekendColor: currentTheme.weekendColor,
            holidayColor: currentTheme.holidayColor,
            todayBackgroundColor: currentTheme.todayBackgroundColor,
            todayTextColor: currentTheme.todayTextColor,
            workdayColor: currentTheme.workdayColor,
            solarTermColor: currentTheme.solarTermColor,
            blurEnabled: currentTheme.blurEnabled,
            blurOpacity: currentTheme.blurOpacity,
            blurMaterial: currentTheme.blurMaterial,
            blurBackground: currentTheme.blurBackground,
            fontSize: fontSize,
            customAccentColor: currentTheme.customAccentColor,
            customTodayColor: currentTheme.customTodayColor
        )
        currentTheme = theme
    }
    
    /// 设置自定义强调色
    func setCustomAccentColor(_ color: Color?) {
        let theme = Theme(
            type: currentTheme.type,
            backgroundColor: currentTheme.backgroundColor,
            textColor: currentTheme.textColor,
            secondaryTextColor: currentTheme.secondaryTextColor,
            accentColor: currentTheme.accentColor,
            gridBackgroundColor: currentTheme.gridBackgroundColor,
            weekendColor: currentTheme.weekendColor,
            holidayColor: currentTheme.holidayColor,
            todayBackgroundColor: currentTheme.todayBackgroundColor,
            todayTextColor: currentTheme.todayTextColor,
            workdayColor: currentTheme.workdayColor,
            solarTermColor: currentTheme.solarTermColor,
            blurEnabled: currentTheme.blurEnabled,
            blurOpacity: currentTheme.blurOpacity,
            blurMaterial: currentTheme.blurMaterial,
            blurBackground: currentTheme.blurBackground,
            fontSize: currentTheme.fontSize,
            customAccentColor: color,
            customTodayColor: currentTheme.customTodayColor
        )
        currentTheme = theme
    }
    
    /// 设置自定义今日颜色
    func setCustomTodayColor(_ color: Color?) {
        let theme = Theme(
            type: currentTheme.type,
            backgroundColor: currentTheme.backgroundColor,
            textColor: currentTheme.textColor,
            secondaryTextColor: currentTheme.secondaryTextColor,
            accentColor: currentTheme.accentColor,
            gridBackgroundColor: currentTheme.gridBackgroundColor,
            weekendColor: currentTheme.weekendColor,
            holidayColor: currentTheme.holidayColor,
            todayBackgroundColor: currentTheme.todayBackgroundColor,
            todayTextColor: currentTheme.todayTextColor,
            workdayColor: currentTheme.workdayColor,
            solarTermColor: currentTheme.solarTermColor,
            blurEnabled: currentTheme.blurEnabled,
            blurOpacity: currentTheme.blurOpacity,
            blurMaterial: currentTheme.blurMaterial,
            blurBackground: currentTheme.blurBackground,
            fontSize: currentTheme.fontSize,
            customAccentColor: currentTheme.customAccentColor,
            customTodayColor: color
        )
        currentTheme = theme
    }
    
    /// 获取有效的强调色（优先使用自定义颜色）
    var effectiveAccentColor: Color {
        return currentTheme.customAccentColor ?? currentTheme.accentColor
    }
    
    /// 获取有效的今日颜色（优先使用自定义颜色）
    var effectiveTodayColor: Color {
        return currentTheme.customTodayColor ?? currentTheme.todayBackgroundColor
    }
}