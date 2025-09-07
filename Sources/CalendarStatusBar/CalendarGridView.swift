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
                
                CalendarDayView(
                    day: day,
                    isWeekend: isWeekend,
                    isToday: isToday,
                    isCurrentMonth: day.isCurrentMonth,
                    weekendColor: weekendColor,
                    holidayColor: holidayColor,
                    todayBackgroundColor: todayBackgroundColor,
                    todayTextColor: todayTextColor,
                    inactiveTextColor: inactiveTextColor
                )
            }
        }
    }
}

struct CalendarDayView: View {
    let day: DayInfo
    let isWeekend: Bool
    let isToday: Bool
    let isCurrentMonth: Bool
    let weekendColor: Color
    let holidayColor: Color
    let todayBackgroundColor: Color
    let todayTextColor: Color
    let inactiveTextColor: Color
    
    // 计算属性，用于判断是否为节假日
    private var isHoliday: Bool {
        // 使用 ChineseCalendarHelper 的同步方法
        return ChineseCalendarHelper.isHolidaySync(day.date)
    }
    
    // 计算属性，用于判断是否为调休上班日
    private var isWorkday: Bool {
        // 使用 ChineseCalendarHelper 的同步方法
        return ChineseCalendarHelper.isWorkdaySync(day.date)
    }
    
    // 计算属性，用于获取节假日名称
    private var holidayName: String? {
        // 使用 ChineseCalendarHelper 的同步方法
        return ChineseCalendarHelper.holidayNameSync(for: day.date)
    }
    
    // 判断是否为公共假日第一天
    private func isFirstDayOfHoliday(_ date: Date) -> Bool {
        let calendar = Calendar.current
        
        // 获取前一天的日期
        guard let previousDay = calendar.date(byAdding: .day, value: -1, to: date) else {
            return false
        }
        
        // 检查当前日期是否为假日
        let isCurrentHoliday = ChineseCalendarHelper.isHolidaySync(date)
        
        // 检查前一天是否为相同类型的假日
        let isPreviousHoliday = ChineseCalendarHelper.isHolidaySync(previousDay)
        
        // 如果当前日期是假日，但前一天不是相同类型的假日，则当前日期是假日的第一天
        return isCurrentHoliday && !isPreviousHoliday
    }
    
    // 获取农历显示文本，遵循优先级规则：
    // 1. 如果有节气，只显示节气
    // 2. 如果是初一，显示月份
    // 3. 其他情况显示农历日期
    private func getLunarDisplayText(for date: Date) -> String {
        let calendar = Calendar(identifier: .chinese)
        let components = calendar.dateComponents([.day], from: date)
        let day = components.day ?? 1
        
        // 检查是否为节气
        if ChineseCalendarHelper.isSolarTerm(date),
           let termName = ChineseCalendarHelper.solarTermName(for: date) {
            return termName
        }
        
        // 检查是否为初一
        if day == 1 {
            return ChineseCalendarHelper.getChineseMonth(for: date) + "月"
        }
        
        // 其他情况显示农历日期
        return ChineseCalendarHelper.getChineseDay(for: date)
    }
    
    var body: some View {
        VStack(spacing: 2) {
            // 在阳历日期前显示 休/班 标识
            HStack(spacing: 2) {
                // 显示 休 或 班 标识
                if isHoliday {
                    Text("休")
                        .font(.system(size: 8))
                        .foregroundColor(.white)
                        .padding(.horizontal, 2)
                        .padding(.vertical, 1)
                        .background(
                            RoundedRectangle(cornerRadius: 3)
                                .fill(holidayColor)
                        )
                } else if isWorkday {
                    Text("班")
                        .font(.system(size: 8))
                        .foregroundColor(.white)
                        .padding(.horizontal, 2)
                        .padding(.vertical, 1)
                        .background(
                            RoundedRectangle(cornerRadius: 3)
                                .fill(Color.orange)
                        )
                } else {
                    // 占位符，保持布局一致。最后试验没有占位符好看
                    // Color.clear.frame(width: 12, height: 12)
                }
                
                // 阳历日期
                HStack(alignment: .center) {
                    Text("\(Calendar.current.component(.day, from: day.date))")
                        .font(.system(size: 13))
                        .foregroundColor(
                            isToday ? todayTextColor :
                                isHoliday ? holidayColor :
                                isWeekend && isCurrentMonth ? weekendColor :
                                isCurrentMonth ? .primary : inactiveTextColor
                        )
                }
            }
            
            HStack {
                Spacer()
                
                // 显示节日和农历日期
                // 节假日第一天显示节日名,其它天只保留 休 字,不显示 节假日 三字, 显示农历
                if let name = holidayName, isFirstDayOfHoliday(day.date) {
                    // 公共假日第一天显示节日名称
                    Text(name)
                        .font(.system(size: 9))
                        .foregroundColor(holidayColor)
                } else if ChineseCalendarHelper.isSolarTerm(day.date),
                          let termName = ChineseCalendarHelper.solarTermName(for: day.date) {
                    // 有节气时只显示节气
                    Text(termName)
                        .font(.system(size: 9))
                        .foregroundColor(.blue)
                } else {
                    // 没有节日和节气时显示农历日期
                    // 农历显示规则：只显示一个农历内容
                    // 1. 如果有节气，只显示节气
                    // 2. 如果是初一，显示月份
                    // 3. 其他情况显示农历日期
                    Text(getLunarDisplayText(for: day.date))
                        .font(.system(size: 9))
                        .foregroundColor(isCurrentMonth ? .primary : inactiveTextColor)
                }
                
                Spacer()
            }
        }
        .frame(height: 35)
        .frame(maxWidth: .infinity)
        .background(
            isToday ? todayBackgroundColor : Color.clear
        )
    }
}