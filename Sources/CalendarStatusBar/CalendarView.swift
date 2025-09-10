import SwiftUI
import AppKit

struct CalendarView: View {
    @ObservedObject var viewModel = CalendarViewModel()
    @StateObject private var eventManager = EventManager.shared
    @StateObject private var themeManager = ThemeManager.shared
    @State private var isEventsDrawerExpanded = false
    
    // 格式化日期
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年MM月dd日 EEEE"
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter.string(from: viewModel.selectedDate)
    }
    
    // 添加自定义字体名称
    private let customFont = "dingliesongtypeface"  // 字体的PostScript名称
    
    /// 获取星座emoji
    private func getZodiacEmoji(for date: Date) -> String {
        let calendar = Calendar.current
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)
        
        switch (month, day) {
        case (1, 20...31), (2, 1...18): return "♒️" // 水瓶座
        case (2, 19...29), (3, 1...20): return "♓️" // 双鱼座
        case (3, 21...31), (4, 1...19): return "♈️" // 白羊座
        case (4, 20...30), (5, 1...20): return "♉️" // 金牛座
        case (5, 21...31), (6, 1...21): return "♊️" // 双子座
        case (6, 22...30), (7, 1...22): return "♋️" // 巨蟹座
        case (7, 23...31), (8, 1...22): return "♌️" // 狮子座
        case (8, 23...31), (9, 1...22): return "♍️" // 处女座
        case (9, 23...30), (10, 1...23): return "♎️" // 天秤座
        case (10, 24...31), (11, 1...22): return "♏️" // 天蝎座
        case (11, 23...30), (12, 1...21): return "♐️" // 射手座
        case (12, 22...31), (1, 1...19): return "♑️" // 摩羯座
        default: return "⭐️" // 默认星星emoji
        }
    }
    
    /// 获取生肖emoji
    private func getAnimalEmoji(for date: Date) -> String {
        let calendar = Calendar.current
        let year = calendar.component(.year, from: date)
        let animalIndex = (year - 4) % 12
        
        switch animalIndex {
        case 0: return "🐭" // 鼠
        case 1: return "🐮" // 牛
        case 2: return "🐯" // 虎
        case 3: return "🐰" // 兔
        case 4: return "🐉" // 龙
        case 5: return "🐍" // 蛇
        case 6: return "🐴" // 马
        case 7: return "🐑" // 羊
        case 8: return "🐵" // 猴
        case 9: return "🐔" // 鸡
        case 10: return "🐶" // 狗
        case 11: return "🐷" // 猪
        default: return "🐾" // 默认爪印emoji
        }
    }
    
    var body: some View {
        ZStack {
            // 主要日历内容
            VStack(spacing: 0) {
                HStack(alignment: .top, spacing: 10) {
                    VStack(spacing: 5) {
                        // 顶部控制栏和星期标题
                        CalendarHeaderView(viewModel: viewModel)
                        
                        // 日历网格
                        CalendarGridView(viewModel: viewModel)
                            .padding(.horizontal)
                        
                        // 底部信息
                        HStack {
                            Text("第\(viewModel.dayOfYear)天·第\(viewModel.weekOfYear)周 \(viewModel.zodiacSign)\(getZodiacEmoji(for: viewModel.currentDate))")
                                .font(.custom(customFont, size: 11))
                                .foregroundColor(themeManager.currentTheme.secondaryTextColor)
                            Spacer()
                            Text("\(viewModel.zodiacMonth)月 \(viewModel.zodiacYear)\(getAnimalEmoji(for: viewModel.currentDate))")
                                .font(.custom(customFont, size: 11))
                                .foregroundColor(themeManager.currentTheme.secondaryTextColor)
                        }
                        .frame(width: 300)
                        .padding(.horizontal)
                    }
                    .frame(maxHeight: .infinity, alignment: .top)
                    .background(themeManager.currentTheme.backgroundColor)
                    
                    // 右侧信息面板
                    VStack(alignment: .leading, spacing: 10) {
                        // 日期信息
                        HStack {
                            Text("\(formattedDate)")
                                .font(.custom(customFont, size: 12))
                                .foregroundColor(themeManager.currentTheme.textColor)
                            Spacer()
                            // 设置按钮
                            Button(action: {
                                // 菜单操作将在AppDelegate中实现
                                NSApp.sendAction(Selector(("showSettingsMenu:")), to: nil, from: nil)
                            }) {
                                Image(systemName: "gear")
                                    .font(.system(size: 12))
                                    .foregroundColor(themeManager.currentTheme.textColor)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        
                        // 天气面板
                        WeatherPanelView(viewModel: viewModel)
                    }
                    .frame(maxWidth: 150, maxHeight: .infinity, alignment: .top)
                    .padding()
                    .background(themeManager.currentTheme.gridBackgroundColor)
                }
                
                // Add a button to manually request calendar access if needed
                if !eventManager.isAuthorized && eventManager.authorizationError != nil {
                    Button("请求日历权限") {
                        eventManager.refreshCalendarAccess()
                    }
                    .font(.caption)
                    .padding(.horizontal)
                    .padding(.bottom, 8)
                    .foregroundColor(themeManager.currentTheme.textColor)
                }
            }
            .padding()
            .background(themeManager.currentTheme.backgroundColor)
            
            // 悬浮式事件抽屉
            VStack {
                Spacer()
                EventsDrawerView(eventManager: eventManager, isExpanded: $isEventsDrawerExpanded)
                    .frame(maxWidth: 500)
                    .padding(.horizontal, 20)
                    .zIndex(1) // 确保抽屉在其他内容之上
            }
        }
        .onChange(of: viewModel.currentDate) { _ in
            // 视图将自动响应 viewModel.currentDate 的变化
            eventManager.loadTodayEvents()
        }
    }
}