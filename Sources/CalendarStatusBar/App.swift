import SwiftUI
import AppKit
import CoreText
import CoreGraphics
import ServiceManagement

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
    
    // 添加析构函数清理资源
    deinit {
        statusBarUpdateTimer?.invalidate()
        if let eventMonitor = eventMonitor {
            NSEvent.removeMonitor(eventMonitor)
        }
        if let quitShortcutMonitor = quitShortcutMonitor {
            NSEvent.removeMonitor(quitShortcutMonitor)
        }
    }
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        setupUI()
        startStatusBarTimer()
        setupKeyboardShortcuts()
        NSApp.setActivationPolicy(.accessory)  // 设置为后台运行模式
        NSApp.activate(ignoringOtherApps: true)  // 激活应用但不显示窗口
        
        // Initialize EventManager to request calendar access
        _ = EventManager.shared
    }
    
    // 拆分设置UI的逻辑
    private func setupUI() {
        registerCustomFonts()
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
                // 更新 CalendarViewModel 中的 currentDate
                DispatchQueue.main.async {
                    if let calendarView = (self?.popover?.contentViewController as? NSHostingController<CalendarView>)?.rootView {
                        calendarView.viewModel.currentDate = Date()
                    }
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
    
    private func registerCustomFonts() {
        do {
            try registerFont(name: Constants.fontName, extension: Constants.fontExtension)
        } catch {
            // Font registration failed
        }
    }
    
    private func registerFont(name: String, extension ext: String) throws {
        guard let fontURL = Bundle.module.url(forResource: name, withExtension: ext) else {
            throw FontError.fileNotFound
        }
        
        guard let fontDataProvider = CGDataProvider(url: fontURL as CFURL) else {
            throw FontError.invalidDataProvider
        }
        
        guard let font = CGFont(fontDataProvider) else {
            throw FontError.invalidFont
        }
        
        var error: Unmanaged<CFError>?
        if !CTFontManagerRegisterGraphicsFont(font, &error) {
            throw FontError.registrationFailed(error?.takeUnretainedValue())
        }
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
        // For now, we'll assume it's off since we can't easily check without deprecated APIs
        loginItem.state = .off
        menu.addItem(loginItem)
        
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
    
    @objc private func toggleLoginItem(_ sender: AnyObject?) {
        if let bundleIdentifier = Bundle.main.bundleIdentifier {
            // Toggle the setting
            // We'll always set it to true for now since we can't easily check the current state
            let newStatus = true
            let success = SMLoginItemSetEnabled(bundleIdentifier as CFString, newStatus)
            
            // Update menu item state if we had a reference
            if let menuItem = sender as? NSMenuItem {
                menuItem.state = success ? .on : .off
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