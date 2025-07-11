import SwiftUI

struct CalendarHeaderView: View {
    @ObservedObject var viewModel: CalendarViewModel
    private let customFont = "dingliesongtypeface"  // 字体的PostScript名称

    var body: some View {
        VStack(spacing: 10) {
            // 顶部控制栏
            HStack(spacing: 6) {
                // 年份选择
                Picker("", selection: $viewModel.selectedYear) {
                    ForEach(Array(viewModel.yearRange), id: \.self) { year in
                        Text(String(year) + "年").tag(year)
                    }
                }
                .frame(width: 85, height: 20) // 限制高度
                .clipped() // 裁剪超出部分
                .labelsHidden()
                .foregroundColor(.primary)
                
                // 月份切换按钮
                Button(action: viewModel.previousMonth) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
                .frame(width: 30, height: 30)
                .contentShape(Rectangle())

                Text("\(viewModel.selectedMonth)月")
                    .font(.system(size: 20, weight: .bold))
                    .font(.custom(customFont, size: 11))
                
                Button(action: viewModel.nextMonth) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
                .frame(width: 30, height: 30)
                .contentShape(Rectangle())
                
                Button(action: viewModel.goToToday) {
                    Text("回到今天")
                        .foregroundColor(.blue.opacity(0.8))
                        .font(.custom(customFont, size: 13))
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal)
            
            // 星期标题
            HStack(spacing: 0) {
                ForEach(["周日", "周一", "周二", "周三", "周四", "周五", "周六"], id: \.self) { weekday in
                    Text(weekday)
                        .frame(maxWidth: .infinity)
                        .foregroundColor(viewModel.isWeekend(weekday) ? Color(red: 0.6, green: 0.4, blue: 0.2) : .secondary)
                        .font(.custom(customFont, size: 15))
                }
            }
            .padding(.horizontal)
        }
    }
}