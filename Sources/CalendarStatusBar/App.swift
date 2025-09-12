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
    
    func applicationDidFinishLaunching(_ notification: Notification) {
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
    
    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem?.button {
            // No icon on status bar, just text with larger font
            let dateString = dateFormatter.string(from: Date())
            let font = NSFont.systemFont(ofSize: Constants.statusBarFontSize)
            let attributes: [NSAttributedString.Key: Any] = [.font: font]
            let attributedString = NSAttributedString(string: dateString, attributes: attributes)
            button.attributedTitle = attributedString
            button.action = #selector(togglePopover(_:))
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
            
            // 更新 CalendarViewModel 中的 currentDate
            DispatchQueue.main.async {
                if let calendarView = (self?.popover?.contentViewController as? NSHostingController<CalendarView>)?.rootView {
                    calendarView.viewModel.currentDate = Date()
                }
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
        
        // Blur effect submenu
        let blurMenu = NSMenu(title: "毛玻璃效果")
        let blurItem = NSMenuItem(title: "毛玻璃效果", action: nil, keyEquivalent: "")
        blurItem.submenu = blurMenu
        
        // Blur enabled toggle
        let blurEnabledItem = NSMenuItem(title: "启用毛玻璃效果", action: #selector(toggleBlurEffect(_:)), keyEquivalent: "")
        blurEnabledItem.state = ThemeManager.shared.currentTheme.blurEnabled ? .on : .off
        blurMenu.addItem(blurEnabledItem)
        
        // Blur opacity slider submenu
        let opacityMenu = NSMenu(title: "透明度")
        let opacityItem = NSMenuItem(title: "透明度", action: nil, keyEquivalent: "")
        opacityItem.submenu = opacityMenu
        
        // Add opacity options (20%, 40%, 60%, 80%, 100%, 120%, 150%)
        let opacities = [0.2, 0.4, 0.6, 0.8, 1.0, 1.2, 1.5]
        let currentOpacity = ThemeManager.shared.currentTheme.blurOpacity
        for opacity in opacities {
            let opacityTitle = "\(Int(opacity * 100))%"
            let opacityMenuItem = NSMenuItem(title: opacityTitle, action: #selector(setBlurOpacity(_:)), keyEquivalent: "")
            opacityMenuItem.representedObject = opacity
            opacityMenuItem.state = (abs(currentOpacity - opacity) < 0.01) ? .on : .off
            opacityMenu.addItem(opacityMenuItem)
        }
        
        blurMenu.addItem(opacityItem)
        
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
    
    /// 检查应用是否已设置为开机启动
    private func isLoginItemEnabled() -> Bool {
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
    
    @objc private func toggleLoginItem(_ sender: AnyObject?) {
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