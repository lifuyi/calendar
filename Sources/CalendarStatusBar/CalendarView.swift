import SwiftUI
import AppKit

struct CalendarView: View {
    @ObservedObject var viewModel = CalendarViewModel()
    @StateObject private var eventManager = EventManager.shared
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
                            Text("第\(viewModel.dayOfYear)天·第\(viewModel.weekOfYear)周 \(viewModel.zodiacSign)月")
                                .font(.custom(customFont, size: 11))
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("\(viewModel.zodiacYear) \(viewModel.zodiacMonth)月")
                                .font(.custom(customFont, size: 11))
                                .foregroundColor(.secondary)
                        }
                        .frame(width: 300)
                        .padding(.horizontal)
                    }
                    .frame(maxHeight: .infinity, alignment: .top)
                    
                    // 右侧信息面板
                    VStack(alignment: .leading, spacing: 10) {
                        // 日期信息
                        HStack {
                            Text("\(formattedDate)")
                                .font(.custom(customFont, size: 12))
                            Spacer()
                            // 设置按钮
                            Button(action: {
                                // 菜单操作将在AppDelegate中实现
                                NSApp.sendAction(Selector(("showSettingsMenu:")), to: nil, from: nil)
                            }) {
                                Image(systemName: "gear")
                                    .font(.system(size: 12))
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        
                        // 天气面板
                        WeatherPanelView(viewModel: viewModel)
                    }
                    .frame(maxWidth: 150, maxHeight: .infinity, alignment: .top)
                    .padding()
                }
                
                // Add a button to manually request calendar access if needed
                if !eventManager.isAuthorized && eventManager.authorizationError != nil {
                    Button("请求日历权限") {
                        eventManager.refreshCalendarAccess()
                    }
                    .font(.caption)
                    .padding(.horizontal)
                    .padding(.bottom, 8)
                }
            }
            .padding()
            // .frame(minWidth: 600, idealWidth: 800, maxWidth: .infinity, minHeight: 250, idealHeight: 350, maxHeight: .infinity)
            
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