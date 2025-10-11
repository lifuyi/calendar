import SwiftUI
import AppKit
import CoreText
import CoreGraphics
import ServiceManagement
import Foundation

class AppDelegate: NSObject, NSApplicationDelegate {
    // 使用常量管理配置
    private enum Constants {
        static let popoverSize = NSSize(width: 600, height: 400)
        static let updateInterval: TimeInterval = 1
        static let fontName = "dingliesong"
        static let fontExtension = "ttf"
        static let dateFormat = "MM月dd日 HH:mm E"
        static let localeIdentifier = "zh_CN"
        static let statusBarFontSize: CGFloat = 14
    }
    
    // 星座emoji映射
    private static let zodiacEmojis: [String: String] = [
        "水瓶座": "♒️",
        "双鱼座": "♓️",
        "白羊座": "♈️",
        "金牛座": "♉️",
        "双子座": "♊️",
        "巨蟹座": "♋️",
        "狮子座": "♌️",
        "处女座": "♍️",
        "天秤座": "♎️",
        "天蝎座": "♏️",
        "射手座": "♐️",
        "摩羯座": "♑️"
    ]
    
    // 生肖emoji映射
    private static let animalEmojis: [String: String] = [
        "鼠": "🐭",
        "牛": "🐮",
        "虎": "🐯",
        "兔": "🐰",
        "龙": "🐉",
        "蛇": "🐍",
        "马": "🐴",
        "羊": "🐑",
        "猴": "🐵",
        "鸡": "🐔",
        "狗": "🐶",
        "猪": "🐷"
    ]
    
    // 使用私有属性存储格式化器
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: Constants.localeIdentifier)
        formatter.dateFormat = Constants.dateFormat
        return formatter
    }()
    
    private var statusBarUpdateTimer: Timer?
    private var statusItem: NSStatusItem?
    private var popover: NSPopover?
    private var eventMonitor: Any?
    private var quitShortcutMonitor: Any?
    private var ipLocationService: IPLocationService?
    private var weatherService: WeatherService?
    
    // 注册自定义字体
    private func registerCustomFont() {
        guard let fontURL = Bundle.main.url(forResource: Constants.fontName, withExtension: Constants.fontExtension) else {
            print("Font file not found: \(Constants.fontName).\(Constants.fontExtension)")
            return
        }
        
        var error: Unmanaged<CFError>?
        let success = CTFontManagerRegisterFontsForURL(fontURL as CFURL, .process, &error)
        
        if !success {
            if let error = error?.takeRetainedValue() {
                print("Failed to register font: \(error)")
            } else {
                print("Failed to register font: Unknown error")
            }
        } else {
            print("Successfully registered custom font: \(Constants.fontName)")
        }
    }
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // 首先注册自定义字体
        registerCustomFont()
        
        // 初始化节气计算器
        LunarBarSolarTermCalculator.initialize()
        
        setupUI()
        startStatusBarTimer()
        setupKeyboardShortcuts()
        NSApp.setActivationPolicy(.accessory)  // 设置为后台运行模式
        NSApp.activate(ignoringOtherApps: true)  // 激活应用但不显示窗口
        
        // Initialize EventManager to request calendar access
        _ = EventManager.shared
        
        // 使用共享的IP位置服务实例
        ipLocationService = IPLocationService.shared
        
        // 获取位置信息
        ipLocationService?.fetchLocation()
        
        // 初始化主题管理器
        _ = ThemeManager.shared
        
        // 设置定时更新管理器
        setupPeriodicUpdates()
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        print("AppDelegate: 应用程序即将退出，停止定时更新")
        PeriodicUpdateManager.shared.stopPeriodicUpdates()
    }
    
    // 拆分设置UI的逻辑
    private func setupUI() {
        NSApp.setActivationPolicy(.accessory)
        setupStatusItem()
        setupPopover()
    }
    
    private func setupKeyboardShortcuts() {
        // Add global keyboard shortcut for quitting the app (Cmd+Q)
        quitShortcutMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            // Check if Cmd+Q is pressed
            if event.modifierFlags.contains(.command) && event.characters == "q" {
                NSApp.terminate(nil)
                return nil // Don't pass the event further
            }
            return event // Pass the event to the next responder
        }
    }
    
    private func setupPeriodicUpdates() {
        print("AppDelegate: 设置定时更新管理器")
        
        // 获取服务实例
        let locationService = IPLocationService.shared
        let weatherService = WeatherService()
        
        // 关联天气服务和位置服务
        weatherService.setLocationService(locationService)
        
        // 设置服务到定时更新管理器
        PeriodicUpdateManager.shared.setServices(
            locationService: locationService,
            weatherService: weatherService
        )
        
        // 启动定时更新
        PeriodicUpdateManager.shared.startPeriodicUpdates()
        
        // 将天气服务存储为实例变量，防止被释放
        self.weatherService = weatherService
    }
    
    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem?.button {
            // No icon on status bar, just text with system font
            let dateString = dateFormatter.string(from: Date())
            let font = NSFont.systemFont(ofSize: Constants.statusBarFontSize)
            let attributes: [NSAttributedString.Key: Any] = [.font: font]
            let attributedString = NSAttributedString(string: dateString, attributes: attributes)
            button.attributedTitle = attributedString
            button.action = #selector(togglePopover(_:))
            button.target = self
            
            // Enable right-click menu
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }
    }
    
    private func setupPopover() {
        popover = NSPopover()
        popover?.contentSize = Constants.popoverSize  // 使用常量中定义的尺寸
        popover?.behavior = .transient
        popover?.animates = true
        popover?.contentViewController = NSHostingController(
            rootView: CalendarView()
                .background(Color(NSColor.windowBackgroundColor))
        )
    }
    
    private func startStatusBarTimer() {
        statusBarUpdateTimer = Timer.scheduledTimer(
            withTimeInterval: Constants.updateInterval,
            repeats: true
        ) { [weak self] _ in
            if let button = self?.statusItem?.button {
                self?.updateStatusBarButton(button)
            }
            
            // 更新 CalendarViewModel 中的 currentDate 和 EventManager
            DispatchQueue.main.async {
                let currentDate = Date()
                // 检查日期是否发生变化，如果变化则刷新今日事件和日历高亮
                CalendarViewModel.shared.updateCurrentDate()
                // 同时更新 EventManager 的今日事件
                EventManager.shared.loadTodayEvents(for: currentDate)
            }
        }
    }
    
    private func updateStatusBarButton(_ button: NSStatusBarButton) {
        let dateString = dateFormatter.string(from: Date())
        let font = NSFont.systemFont(ofSize: Constants.statusBarFontSize)
        let attributes: [NSAttributedString.Key: Any] = [.font: font]
        let attributedString = NSAttributedString(string: dateString, attributes: attributes)
        button.attributedTitle = attributedString
    }
    
    /// 获取星座
    private func getZodiacSign(for date: Date) -> String {
        let month = Calendar.current.component(.month, from: date)
        let day = Calendar.current.component(.day, from: date)
        
        switch (month, day) {
        case (1, 20...31), (2, 1...18): return "水瓶座"
        case (2, 19...29), (3, 1...20): return "双鱼座"
        case (3, 21...31), (4, 1...19): return "白羊座"
        case (4, 20...30), (5, 1...20): return "金牛座"
        case (5, 21...31), (6, 1...21): return "双子座"
        case (6, 22...30), (7, 1...22): return "巨蟹座"
        case (7, 23...31), (8, 1...22): return "狮子座"
        case (8, 23...31), (9, 1...22): return "处女座"
        case (9, 23...30), (10, 1...23): return "天秤座"
        case (10, 24...31), (11, 1...22): return "天蝎座"
        case (11, 23...30), (12, 1...21): return "射手座"
        case (12, 22...31), (1, 1...19): return "摩羯座"
        default: return "未知"
        }
    }
    
    /// 获取生肖
    private func getChineseZodiacAnimal(for date: Date) -> String {
        let animals = ["鼠", "牛", "虎", "兔", "龙", "蛇", "马", "羊", "猴", "鸡", "狗", "猪"]
        let year = Calendar.current.component(.year, from: date)
        let animalIndex = (year - 4) % 12
        return animals[animalIndex >= 0 ? animalIndex : animalIndex + 12]
    }
    
    @objc private func togglePopover(_ sender: AnyObject?) {
        // Check if this was a right-click
        if let event = NSApp.currentEvent, event.type == .rightMouseUp {
            showSettingsMenu(sender)
            return
        }
        
        if let button = statusItem?.button {
            if popover?.isShown == true {
                popover?.performClose(sender)
                // Remove event monitor when closing popover
                if let eventMonitor = eventMonitor {
                    NSEvent.removeMonitor(eventMonitor)
                    self.eventMonitor = nil
                }
            } else {
                popover?.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
                // Add event monitor to close popover when clicking outside
                eventMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { [weak self] event in
                    if let popover = self?.popover, popover.isShown {
                        popover.performClose(nil)
                        // Remove event monitor after closing
                        if let eventMonitor = self?.eventMonitor {
                            NSEvent.removeMonitor(eventMonitor)
                            self?.eventMonitor = nil
                        }
                    }
                }
            }
        }
    }
    
    @objc private func showSettingsMenu(_ sender: AnyObject?) {
        let menu = NSMenu()
        
        // Start at login
        let loginItem = NSMenuItem(title: "开机启动", action: #selector(toggleLoginItem(_:)), keyEquivalent: "")
        loginItem.state = isLoginItemEnabled() ? .on : .off
        menu.addItem(loginItem)
        
        menu.addItem(NSMenuItem.separator())
        
        // Theme selection submenu
        let themeMenu = NSMenu(title: "主题")
        let themeItem = NSMenuItem(title: "主题", action: nil, keyEquivalent: "")
        themeItem.submenu = themeMenu
        
        // Add theme options
        let currentTheme = ThemeManager.shared.currentTheme.type
        for themeType in ThemeType.allCases {
            let item = NSMenuItem(title: themeType.displayName, action: #selector(selectTheme(_:)), keyEquivalent: "")
            item.representedObject = themeType.rawValue
            item.state = (currentTheme == themeType) ? .on : .off
            themeMenu.addItem(item)
        }
        
        menu.addItem(themeItem)
        
        menu.addItem(NSMenuItem.separator())
        
        // 毛玻璃效果子菜单 (Enhanced)
        let blurMenu = NSMenu(title: "毛玻璃效果")
        let blurItem = NSMenuItem(title: "毛玻璃效果", action: nil, keyEquivalent: "")
        blurItem.submenu = blurMenu
        
        // 启用/禁用毛玻璃效果
        let blurEnabledItem = NSMenuItem(title: "启用毛玻璃效果", action: #selector(toggleBlurEffect(_:)), keyEquivalent: "")
        blurEnabledItem.state = ThemeManager.shared.currentTheme.blurEnabled ? .on : .off
        blurMenu.addItem(blurEnabledItem)
        
        blurMenu.addItem(NSMenuItem.separator())
        
        // 虚化方向子菜单
        let blurDirectionMenu = NSMenu(title: "虚化方向")
        let blurDirectionItem = NSMenuItem(title: "虚化方向", action: nil, keyEquivalent: "")
        blurDirectionItem.submenu = blurDirectionMenu
        
        let foregroundBlurItem = NSMenuItem(title: "前景虚化", action: #selector(setBlurDirection(_:)), keyEquivalent: "")
        foregroundBlurItem.representedObject = false
        foregroundBlurItem.state = !ThemeManager.shared.currentTheme.blurBackground ? .on : .off
        blurDirectionMenu.addItem(foregroundBlurItem)
        
        let backgroundBlurItem = NSMenuItem(title: "背景虚化", action: #selector(setBlurDirection(_:)), keyEquivalent: "")
        backgroundBlurItem.representedObject = true
        backgroundBlurItem.state = ThemeManager.shared.currentTheme.blurBackground ? .on : .off
        blurDirectionMenu.addItem(backgroundBlurItem)
        
        blurMenu.addItem(blurDirectionItem)
        
        // 虚化材质子菜单
        let materialMenu = NSMenu(title: "虚化材质")
        let materialItem = NSMenuItem(title: "虚化材质", action: nil, keyEquivalent: "")
        materialItem.submenu = materialMenu
        
        for material in BlurMaterial.allCases {
            let materialMenuItem = NSMenuItem(title: material.displayName, action: #selector(setBlurMaterial(_:)), keyEquivalent: "")
            materialMenuItem.representedObject = material.rawValue
            materialMenuItem.state = ThemeManager.shared.currentTheme.blurMaterial == material ? .on : .off
            materialMenu.addItem(materialMenuItem)
        }
        
        blurMenu.addItem(materialItem)
        
        // 虚化强度子菜单
        let opacityMenu = NSMenu(title: "虚化强度")
        let opacityItem = NSMenuItem(title: "虚化强度", action: nil, keyEquivalent: "")
        opacityItem.submenu = opacityMenu
        
        let currentOpacity = ThemeManager.shared.currentTheme.blurOpacity
        for opacity in [0.3, 0.5, 0.7, 0.8, 0.9, 1.0] {
            let opacityTitle = String(format: "%.0f%%", opacity * 100)
            let opacityMenuItem = NSMenuItem(title: opacityTitle, action: #selector(setBlurOpacity(_:)), keyEquivalent: "")
            opacityMenuItem.representedObject = opacity
            opacityMenuItem.state = (abs(currentOpacity - opacity) < 0.01) ? .on : .off
            opacityMenu.addItem(opacityMenuItem)
        }
        
        blurMenu.addItem(opacityItem)
        
        blurMenu.addItem(NSMenuItem.separator())
        
        // 快速预设
        let presetsMenu = NSMenu(title: "快速预设")
        let presetsItem = NSMenuItem(title: "快速预设", action: nil, keyEquivalent: "")
        presetsItem.submenu = presetsMenu
        
        let subtlePresetItem = NSMenuItem(title: "柔和效果", action: #selector(applyBlurPreset(_:)), keyEquivalent: "")
        subtlePresetItem.representedObject = "subtle"
        presetsMenu.addItem(subtlePresetItem)
        
        let standardPresetItem = NSMenuItem(title: "标准效果", action: #selector(applyBlurPreset(_:)), keyEquivalent: "")
        standardPresetItem.representedObject = "standard"
        presetsMenu.addItem(standardPresetItem)
        
        let strongPresetItem = NSMenuItem(title: "强烈效果", action: #selector(applyBlurPreset(_:)), keyEquivalent: "")
        strongPresetItem.representedObject = "strong"
        presetsMenu.addItem(strongPresetItem)
        
        blurMenu.addItem(presetsItem)
        
        blurMenu.addItem(NSMenuItem.separator())
        
        // 高级设置
        let advancedSettingsItem = NSMenuItem(title: "高级设置...", action: #selector(showAdvancedBlurSettings(_:)), keyEquivalent: "")
        blurMenu.addItem(advancedSettingsItem)
        
        menu.addItem(blurItem)
        
        menu.addItem(NSMenuItem.separator())
        
        // GitHub link
        let githubItem = NSMenuItem(title: "GitHub", action: #selector(openGitHub(_:)), keyEquivalent: "")
        menu.addItem(githubItem)
        
        // Check updates
        let updateItem = NSMenuItem(title: "检查更新", action: #selector(checkForUpdates(_:)), keyEquivalent: "")
        menu.addItem(updateItem)
        
        menu.addItem(NSMenuItem.separator())
        
        // Quit
        let quitItem = NSMenuItem(title: "退出", action: #selector(quitApp(_:)), keyEquivalent: "q")
        quitItem.keyEquivalentModifierMask = .command
        menu.addItem(quitItem)
        
        // Show menu
        menu.popUp(positioning: nil, at: NSEvent.mouseLocation, in: nil)
    }
    
    @objc private func selectTheme(_ sender: AnyObject?) {
        guard let menuItem = sender as? NSMenuItem,
              let themeRawValue = menuItem.representedObject as? String,
              let themeType = ThemeType(rawValue: themeRawValue) else {
            return
        }
        
        // 更新主题
        ThemeManager.shared.setTheme(themeType)
        
        // 更新菜单项状态
        if let themeMenu = (sender as? NSMenuItem)?.submenu {
            for item in themeMenu.items {
                if let itemThemeRawValue = item.representedObject as? String {
                    item.state = (itemThemeRawValue == themeType.rawValue) ? .on : .off
                }
            }
        }
    }
    
    @objc private func toggleBlurEffect(_ sender: AnyObject?) {
        let themeManager = ThemeManager.shared
        let newEnabledState = !themeManager.currentTheme.blurEnabled
        themeManager.setBlurEffect(enabled: newEnabledState, opacity: themeManager.currentTheme.blurOpacity)
        
        // 更新菜单项状态
        if let menuItem = sender as? NSMenuItem {
            menuItem.state = newEnabledState ? .on : .off
        }
    }
    
    @objc private func setBlurOpacity(_ sender: AnyObject?) {
        guard let menuItem = sender as? NSMenuItem,
              let opacity = menuItem.representedObject as? Double else {
            return
        }
        
        let themeManager = ThemeManager.shared
        themeManager.setBlurEffect(enabled: themeManager.currentTheme.blurEnabled, opacity: opacity)
        
        // 更新菜单项状态
        if let opacityMenu = (sender as? NSMenuItem)?.menu {
            for item in opacityMenu.items {
                if let itemOpacity = item.representedObject as? Double {
                    item.state = (abs(itemOpacity - opacity) < 0.01) ? .on : .off
                }
            }
        }
    }
    
    @objc private func setBlurDirection(_ sender: AnyObject?) {
        guard let menuItem = sender as? NSMenuItem,
              let blurBackground = menuItem.representedObject as? Bool else { return }
        
        ThemeManager.shared.setBlurBackground(blurBackground)
        
        // Update menu states
        if let directionMenu = (sender as? NSMenuItem)?.menu {
            for item in directionMenu.items {
                item.state = .off
            }
        }
        menuItem.state = .on
    }
    
    @objc private func setBlurMaterial(_ sender: AnyObject?) {
        guard let menuItem = sender as? NSMenuItem,
              let materialRawValue = menuItem.representedObject as? String,
              let material = BlurMaterial(rawValue: materialRawValue) else { return }
        
        ThemeManager.shared.setBlurMaterial(material)
        
        // Update menu states
        if let materialMenu = (sender as? NSMenuItem)?.menu {
            for item in materialMenu.items {
                item.state = .off
            }
        }
        menuItem.state = .on
    }
    
    @objc private func applyBlurPreset(_ sender: AnyObject?) {
        guard let menuItem = sender as? NSMenuItem,
              let presetType = menuItem.representedObject as? String else { return }
        
        switch presetType {
        case "subtle":
            ThemeManager.shared.setBlurEffect(enabled: true, opacity: 0.6)
            ThemeManager.shared.setBlurMaterial(.thin)
            ThemeManager.shared.setBlurBackground(true)
        case "standard":
            ThemeManager.shared.setBlurEffect(enabled: true, opacity: 0.8)
            ThemeManager.shared.setBlurMaterial(.regular)
            ThemeManager.shared.setBlurBackground(true)
        case "strong":
            ThemeManager.shared.setBlurEffect(enabled: true, opacity: 0.95)
            ThemeManager.shared.setBlurMaterial(.thick)
            ThemeManager.shared.setBlurBackground(true)
        default:
            break
        }
    }
    
    @objc private func showAdvancedBlurSettings(_ sender: AnyObject?) {
        // Create and show the advanced settings window
        let advancedSettingsView = AdvancedSettingsView(themeManager: ThemeManager.shared)
        let hostingController = NSHostingController(rootView: advancedSettingsView)
        
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 500, height: 700),
            styleMask: [.titled, .closable, .resizable],
            backing: .buffered,
            defer: false
        )
        
        window.title = "毛玻璃效果高级设置"
        window.contentViewController = hostingController
        window.center()
        window.makeKeyAndOrderFront(nil)
        
        // Keep a reference to prevent the window from being deallocated
        NSApp.activate(ignoringOtherApps: true)
    }
    
    /// 检查应用是否已设置为开机启动
    internal func isLoginItemEnabled() -> Bool {
        guard let bundleIdentifier = Bundle.main.bundleIdentifier else {
            return false
        }
        
        // 使用SMAppService检查登录项状态（macOS 13.0+）
        if #available(macOS 13.0, *) {
            let status = SMAppService.mainApp.status
            return status == .enabled
        } else {
            // 在较早的macOS版本上使用旧方法
            return isLoginItemEnabledLegacy(bundleIdentifier: bundleIdentifier)
        }
    }
    
    /// 使用传统方法检查登录项状态
    private func isLoginItemEnabledLegacy(bundleIdentifier: String) -> Bool {
        // 使用已弃用但仍然有效的API检查登录项状态
        let jobDict = SMJobCopyDictionary(kSMDomainUserLaunchd, bundleIdentifier as CFString)?.takeRetainedValue() as? [String: Any]
        return jobDict?["OnDemand"] as? Bool != false
    }
    
    @objc internal func toggleLoginItem(_ sender: AnyObject?) {
        if let bundleIdentifier = Bundle.main.bundleIdentifier {
            // 获取当前状态并切换
            let currentState = isLoginItemEnabled()
            let newState = !currentState
            
            // 根据macOS版本使用相应的API
            let success: Bool
            if #available(macOS 13.0, *) {
                do {
                    if newState {
                        try SMAppService.mainApp.register()
                    } else {
                        try SMAppService.mainApp.unregister()
                    }
                    success = true
                } catch {
                    success = false
                }
            } else {
                // 在较早的macOS版本上使用旧方法
                success = SMLoginItemSetEnabled(bundleIdentifier as CFString, newState)
            }
            
            // 更新菜单项状态
            if let menuItem = sender as? NSMenuItem {
                menuItem.state = success && newState ? .on : .off
            }
            
            // 如果设置失败，显示错误信息
            if !success {
                let alert = NSAlert()
                alert.messageText = "设置失败"
                alert.informativeText = "无法设置开机启动选项，请稍后重试。"
                alert.alertStyle = .warning
                alert.addButton(withTitle: "确定")
                alert.runModal()
            }
        }
    }
    
    @objc private func openGitHub(_ sender: AnyObject?) {
        if let url = URL(string: "https://github.com/lifuyi/calendar") {
            NSWorkspace.shared.open(url)
        }
    }
    
    @objc private func checkForUpdates(_ sender: AnyObject?) {
        // For now, just open the GitHub releases page
        if let url = URL(string: "https://github.com/lifuyi/calendar/releases") {
            NSWorkspace.shared.open(url)
        }
    }
    
    @objc private func quitApp(_ sender: AnyObject?) {
        NSApp.terminate(nil)
    }
}

// 自定义错误类型
enum FontError: Error {
    case fileNotFound
    case invalidDataProvider
    case invalidFont
    case registrationFailed(CFError?)
}

struct CalendarStatusBarApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            EmptyView()
        }
        .windowStyle(.hiddenTitleBar)
    }
}