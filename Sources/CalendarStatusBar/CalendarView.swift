import SwiftUI
import AppKit

struct CalendarView: View {
    @ObservedObject var viewModel = CalendarViewModel()
    
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
        HStack(spacing: 10) {
            VStack(spacing: 10) {
                // 顶部控制栏和星期标题
                CalendarHeaderView(viewModel: viewModel)
                
                // 日历网格
                CalendarGridView(viewModel: viewModel)
                    .padding(.horizontal)
                
                Spacer(minLength: 0)
                
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
                .frame(width: 350)
                .padding(.horizontal)
            }
            
            // 右侧信息面板
            VStack(alignment: .leading, spacing: 10) {
                // 日期信息
                Text("日期: \(formattedDate)")
                    .font(.custom(customFont, size: 12))
                
                // 天气面板
                WeatherPanelView(viewModel: viewModel)
            }
            .frame(width: 180)
            .padding()
        }
        .padding()
        .onChange(of: viewModel.currentDate) { _ in
            // 视图将自动响应 viewModel.currentDate 的变化
        }
    }
}