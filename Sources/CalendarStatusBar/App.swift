import SwiftUI
import AppKit
import CoreText
import CoreGraphics

class AppDelegate: NSObject, NSApplicationDelegate {
    // 使用常量管理配置
    private enum Constants {
        static let popoverSize = NSSize(width: 350, height: 350)
        static let updateInterval: TimeInterval = 1
        static let fontName = "dingliesong"
        static let fontExtension = "ttf"
        static let dateFormat = "MM月dd日 HH:mm E"
        static let localeIdentifier = "zh_CN"
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
    
    // 添加析构函数清理资源
    deinit {
        statusBarUpdateTimer?.invalidate()
    }
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        setupUI()
        startStatusBarTimer()
        NSApp.setActivationPolicy(.accessory)  // 设置为后台运行模式
        NSApp.activate(ignoringOtherApps: true)  // 激活应用但不显示窗口
    }
    
    // 拆分设置UI的逻辑
    private func setupUI() {
        registerCustomFonts()
        NSApp.setActivationPolicy(.accessory)
        setupStatusItem()
        setupPopover()
    }
    
    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem?.button {
            // 设置状态栏图标
            if let iconImage = NSImage(named: "StatusBarIcon") {
                iconImage.isTemplate = true  // 使图标适应深色/浅色模式
                button.image = iconImage
            }
            button.action = #selector(togglePopover(_:))
        }
    }
    
    private func setupPopover() {
        popover = NSPopover()
        popover?.contentSize = Constants.popoverSize
        popover?.behavior = .semitransient
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
                if let calendarView = (self?.popover?.contentViewController as? NSHostingController<CalendarView>)?.rootView {
                    calendarView.viewModel.currentDate = Date()
                }
            }
        }
    }
    
    private func updateStatusBarButton(_ button: NSStatusBarButton) {
        button.title = dateFormatter.string(from: Date())
    }
    
    private func registerCustomFonts() {
        do {
            try registerFont(name: Constants.fontName, extension: Constants.fontExtension)
        } catch {
            print("字体注册失败: \(error)")
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
            } else {
                popover?.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            }
        }
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