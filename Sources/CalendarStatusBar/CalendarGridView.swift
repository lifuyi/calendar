import SwiftUI

struct CalendarGridView: View {
    @ObservedObject var viewModel: CalendarViewModel
    
    // 定义颜色常量
    private let weekendColor = Color(red: 0.6, green: 0.4, blue: 0.2)
    private let holidayColor = Color.red
    private let todayBackgroundColor = Color.blue.opacity(0.3)
    private let todayTextColor = Color.blue
    private let inactiveTextColor = Color.gray
    
    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 0), count: 7), spacing: 0) {
            ForEach(viewModel.days.indices, id: \.self) { index in
                let day = viewModel.days[index]
                let isWeekend = viewModel.isWeekendDate(day.date)
                let isToday = viewModel.isToday(day.date)
                let isHoliday = viewModel.isHoliday(day.date)
                let holidayName = viewModel.holidayName(for: day.date)
                
                VStack(spacing: 2) {
                    Text("\(Calendar.current.component(.day, from: day.date))")
                        .font(.system(size: 13))
                        .foregroundColor(
                            isToday ? todayTextColor :
                                isHoliday ? holidayColor :
                                isWeekend && day.isCurrentMonth ? weekendColor :
                                day.isCurrentMonth ? .primary : inactiveTextColor
                        )
                    
                    // 优先显示节日或节气，如果都没有则显示农历日期
                    if let name = holidayName {
                        HStack(spacing: 1) {
                        if ChineseCalendarHelper.isHoliday(day.date) {
                    Text("休")
                        .font(.system(size: 8))
                        .foregroundColor(.white)
                        .padding(.horizontal, 2)
                        .padding(.vertical, 1)
                        .background(
                            RoundedRectangle(cornerRadius: 5)
                                .fill(holidayColor)  // 使用传入的holidayColor
                        )
                    }

                        // 节日名称
                        Text(name)
                            .font(.system(size: 9))
                            .foregroundColor(holidayColor)
                    }.frame(minHeight: 12)
                    } else if ChineseCalendarHelper.isSolarTerm(day.date),
                              let termName = ChineseCalendarHelper.solarTermName(for: day.date) {
                        Text(termName)
                            .font(.system(size: 9))
                            .foregroundColor(.blue)
                    } else {
                        Text(ChineseCalendarHelper.getChineseDay(for: day.date))
                            .font(.system(size: 9))
                            .foregroundColor(day.isCurrentMonth ? .primary : inactiveTextColor)
                    }
                }
                .frame(height: 35)
                .frame(maxWidth: .infinity)
                .background(
                    isToday ? todayBackgroundColor : Color.clear
                )
          
            }
        }
    }
}