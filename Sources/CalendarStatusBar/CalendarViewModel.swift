import SwiftUI
import Foundation
import Combine

@MainActor
class CalendarViewModel: ObservableObject {
    // 共享实例
    static let shared = CalendarViewModel()    
    // 天气服务
    var weatherService: WeatherService
    
    // 定位服务
    var locationService: IPLocationService
    
    // 天气相关的状态
    @Published var temperature: String = "--"
    @Published var weatherInfo: String = "--"
    @Published var humidity: String = "--"
    @Published var airPressure: String = "--"
    @Published var rain: String = "--"
    @Published var feelTemperature: String = "--"
    @Published var isWeatherLoading: Bool = false
    @Published var weatherError: String? = nil
    @Published var selectedDate = Date()
    @Published var currentDate = Date()
    private var lastKnownDate = Date()
    @Published var selectedYear: Int
    @Published var selectedMonth: Int
    @Published var days: [DayInfo] = []
    
    // 年份范围：1900-2075
    public let yearRange = 1900...2075
    
    // 添加缓存属性
    private let calendar = Calendar(identifier: .gregorian)
    
    // 计算属性，生成一个包含当前选中年份前后各5年的年份范围，总共10年
    // 显示全部年份范围
    var limitedYearRange: [Int] {
        return Array(yearRange)
    }
    
    init() {
        let calendar = Calendar.current
        let currentDate = Date()
        // 使用共享的定位服务实例
        locationService = IPLocationService.shared
        
        // 初始化天气服务，使用当前位置作为默认值
        weatherService = WeatherService(latitude: locationService.latitude, longitude: locationService.longitude)
        
        // 设置天气服务的定位服务
        weatherService.setLocationService(locationService)
        
        _selectedYear = Published(initialValue: calendar.component(.year, from: currentDate))
        _selectedMonth = Published(initialValue: calendar.component(.month, from: currentDate))
        updateDays()
        
        // 设置天气数据更新回调
        setupWeatherBindings()
        
        // 设置日期变化监听
        setupDateChangeNotification()
        
        // 不再在这里调用 fetchLocation，因为 AppDelegate 已经调用了
    }
    
    // 缓存上一次计算的年月
    private var lastCalculatedYear: Int = 0
    private var lastCalculatedMonth: Int = 0
    
    // 计算并更新当前显示的日期数组
    private func updateDays() {
        // 移除了年月变化检查，确保每次都会重新计算
        lastCalculatedYear = selectedYear
        lastCalculatedMonth = selectedMonth
        
        var days = [DayInfo]()
        days.reserveCapacity(42) // 预分配容量
        
        // 使用一次性创建的 DateComponents
        let components = DateComponents(year: selectedYear, month: selectedMonth, day: 1)
        
        guard let firstDayOfMonth = calendar.date(from: components),
              let range = calendar.range(of: .day, in: .month, for: firstDayOfMonth) else {
            self.days = []
            return
        }
        
        // 获取月份第一天是星期几
        let firstWeekday = calendar.component(.weekday, from: firstDayOfMonth)
        
        // 优化上个月日期的添加
        if firstWeekday > 1 {
            let previousMonth = calendar.date(byAdding: .month, value: -1, to: firstDayOfMonth)!
            let daysInPreviousMonth = calendar.range(of: .day, in: .month, for: previousMonth)!.count
            let previousMonthComponents = calendar.dateComponents([.year, .month], from: previousMonth)
            
            // 批量创建上个月的日期
            for day in (daysInPreviousMonth - firstWeekday + 2)...daysInPreviousMonth {
                var components = previousMonthComponents
                components.day = day
                if let date = calendar.date(from: components) {
                    days.append(DayInfo(date: date, isCurrentMonth: false))
                }
            }
        }
        
        // 优化当前月日期的添加
        let currentMonthComponents = calendar.dateComponents([.year, .month], from: firstDayOfMonth)
        for day in range {
            var components = currentMonthComponents
            components.day = day
            if let date = calendar.date(from: components) {
                days.append(DayInfo(date: date, isCurrentMonth: true))
            }
        }
        
        // 优化下个月日期的添加
        let totalRows = (days.count + 6) / 7  // 计算需要的行数
        let targetDays = totalRows * 7         // 向上取整到7的倍数
        let remainingDays = targetDays - days.count
        if remainingDays > 0 {
            let nextMonth = calendar.date(byAdding: .month, value: 1, to: firstDayOfMonth)!
            let nextMonthComponents = calendar.dateComponents([.year, .month], from: nextMonth)
            
            // 批量创建下个月的日期
            for day in 1...remainingDays {
                var components = nextMonthComponents
                components.day = day
                if let date = calendar.date(from: components) {
                    days.append(DayInfo(date: date, isCurrentMonth: false))
                }
            }
        }
        
        self.days = days
    }
    
    // 判断是否为周末
    func isWeekend(_ weekday: String) -> Bool {
        return weekday == "周六" || weekday == "周日"
    }
    
    // 判断日期是否为周末
    func isWeekendDate(_ date: Date) -> Bool {
        let weekday = calendar.component(.weekday, from: date)
        return weekday == 1 || weekday == 7 // 1是周日，7是周六
    }
    
    // 优化判断是否为今天的方法 - 使用 currentDate 而不是缓存的组件
    func isToday(_ date: Date) -> Bool {
        let todayComponents = calendar.dateComponents([.year, .month, .day], from: currentDate)
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        return components.year == todayComponents.year &&
               components.month == todayComponents.month &&
               components.day == todayComponents.day
    }
    
    // 判断是否为法定节假日
    func isHoliday(_ date: Date) -> Bool {
        // 使用新的 HolidayManager 来判断节假日
        let year = calendar.component(.year, from: date)
        let monthDayFormatter = DateFormatter()
        monthDayFormatter.dateFormat = "MMdd"
        let monthDayString = monthDayFormatter.string(from: date)
        
        if let holidayType = HolidayManager.default.typeOf(year: year, monthDay: monthDayString) {
            return holidayType == .holiday
        }
        
        // 如果 HolidayManager 没有数据，则回退到原来的方法
        return ChineseCalendarHelper.isHoliday(date)
    }
    
    // 获取节假日名称
    func holidayName(for date: Date) -> String? {
        // 使用新的 HolidayManager 来获取节假日名称
        let year = calendar.component(.year, from: date)
        let monthDayFormatter = DateFormatter()
        monthDayFormatter.dateFormat = "MMdd"
        let monthDayString = monthDayFormatter.string(from: date)
        
        if let holidayType = HolidayManager.default.typeOf(year: year, monthDay: monthDayString) {
            if holidayType == .holiday {
                // 对于通过 HolidayManager 管理的节假日，我们需要映射到具体的名称
                switch monthDayString {
                case "0101": return "元旦"
                case "0501": return "劳动节"
                case "1001": return "国庆节"
                // 可以根据需要添加更多节日
                default: 
                    // 尝试从 ChineseCalendarHelper 获取名称
                    if let name = ChineseCalendarHelper.holidayName(for: date) {
                        return name
                    }
                    return "节假日"
                }
            }
        }
        
        // 如果 HolidayManager 没有数据，则回退到原来的方法
        return ChineseCalendarHelper.holidayName(for: date)
    }
    
    // 同步版本的方法，用于视图中调用
    func isHolidaySync(_ date: Date) -> Bool {
        // 在主线程中执行异步方法并等待结果
        return isHoliday(date)
    }
    
    func holidayNameSync(for date: Date) -> String? {
        // 在主线程中执行异步方法并等待结果
        return holidayName(for: date)
    }
    
    // 更新选中的日期
    func updateSelectedDate() {
        var components = DateComponents()
        components.year = selectedYear
        components.month = selectedMonth
        components.day = 1
        
        if let date = calendar.date(from: components) {
            selectedDate = date
        }
        updateDays()
        // 强制触发视图更新
        objectWillChange.send()
    }
    
    // 上个月
    // 优化月份切换逻辑
    func previousMonth() {
        if selectedMonth == 1 && selectedYear > yearRange.lowerBound {
            selectedYear -= 1
            selectedMonth = 12
        } else if selectedMonth > 1 {
            selectedMonth -= 1
        }
        updateDays()
        // 强制触发视图更新
        objectWillChange.send()
    }
    
    func nextMonth() {
        if selectedMonth == 12 && selectedYear < yearRange.upperBound {
            selectedYear += 1
            selectedMonth = 1
        } else if selectedMonth < 12 {
            selectedMonth += 1
        }
        updateDays()
        // 强制触发视图更新
        objectWillChange.send()
    }
    
    // 设置天气数据绑定
    private func setupWeatherBindings() {
        // 监听天气服务的变化
        weatherService.$temperature.sink { [weak self] temp in
            self?.temperature = temp
        }.store(in: &cancellables)
        
        weatherService.$weatherInfo.sink { [weak self] info in
            self?.weatherInfo = info
        }.store(in: &cancellables)
        
        weatherService.$humidity.sink { [weak self] humidity in
            self?.humidity = humidity
        }.store(in: &cancellables)
        
        weatherService.$airPressure.sink { [weak self] pressure in
            self?.airPressure = pressure
        }.store(in: &cancellables)
        
        weatherService.$rain.sink { [weak self] rain in
            self?.rain = rain
        }.store(in: &cancellables)
        
        weatherService.$feelTemperature.sink { [weak self] feelTemp in
            self?.feelTemperature = feelTemp
        }.store(in: &cancellables)
        
        weatherService.$isLoading.sink { [weak self] loading in
            self?.isWeatherLoading = loading
        }.store(in: &cancellables)
        
        weatherService.$errorMessage.sink { [weak self] error in
            self?.weatherError = error
        }.store(in: &cancellables)
    }
    
    // 用于存储取消令牌
    private var cancellables = Set<AnyCancellable>()
    
    // 设置日期变化通知监听
    private func setupDateChangeNotification() {
        // 监听系统日期变化通知
        NotificationCenter.default.addObserver(
            forName: .NSCalendarDayChanged,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            print("系统检测到日期变化")
            Task { @MainActor in
                self?.handleDateChange()
            }
        }
        
        // 监听时区变化通知
        NotificationCenter.default.addObserver(
            forName: .NSSystemTimeZoneDidChange,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            print("系统检测到时区变化")
            Task { @MainActor in
                self?.handleDateChange()
            }
        }
    }
    
    // 处理日期变化
    private func handleDateChange() {
        let newDate = Date()
        let calendar = Calendar.current
        let newYear = calendar.component(.year, from: newDate)
        let newMonth = calendar.component(.month, from: newDate)
        
        currentDate = newDate
        lastKnownDate = newDate
        
        // 检查是否需要切换到新的月份和年份
        if selectedYear != newYear || selectedMonth != newMonth {
            selectedYear = newYear
            selectedMonth = newMonth
            updateDays()
            print("日期跨月/跨年变化，切换到新的月份: \(newYear)年\(newMonth)月")
        }
        
        print("处理日期变化，强制更新今天高亮")
        // 强制触发视图更新以确保"今天"的高亮同步
        objectWillChange.send()
    }
    
    // 更新当前日期（仅更新实际的当前时间，不影响用户选择的显示日期）
    func updateCurrentDate() {
        let newDate = Date()
        let calendar = Calendar.current
        
        // 检查日期是否真的发生了变化（跨日）
        let lastDateComponents = calendar.dateComponents([.year, .month, .day], from: lastKnownDate)
        let newDateComponents = calendar.dateComponents([.year, .month, .day], from: newDate)
        
        let dateChanged = lastDateComponents.year != newDateComponents.year ||
                         lastDateComponents.month != newDateComponents.month ||
                         lastDateComponents.day != newDateComponents.day
        
        currentDate = newDate
        lastKnownDate = newDate
        
        // 如果日期发生了变化，强制刷新今天的高亮显示
        if dateChanged {
            let newYear = newDateComponents.year!
            let newMonth = newDateComponents.month!
            
            // 检查是否需要切换到新的月份和年份
            if selectedYear != newYear || selectedMonth != newMonth {
                selectedYear = newYear
                selectedMonth = newMonth
                updateDays()
                print("日期跨月/跨年变化，切换到新的月份: \(newYear)年\(newMonth)月")
            }
            
            print("日期发生变化，更新今天高亮显示")
            // 强制触发视图更新以确保"今天"的高亮同步
            objectWillChange.send()
        }
    }
    
    // 回到今天
    func goToToday() {
        selectedYear = calendar.component(.year, from: currentDate)
        selectedMonth = calendar.component(.month, from: currentDate)
        updateDays()
    }
    
    // 获取当前年份的天干地支和生肖
    func zodiacYear(for date: Date) -> String {
        return ChineseCalendarHelper.getChineseYearText(for: date)
    }
    
    // 获取当前月份的农历月份
    func zodiacMonth(for date: Date) -> String {
        return ChineseCalendarHelper.getChineseMonth(for: date)
    }
    
    // 获取当前是一年中的第几天和第几周
    func dayOfYear(for date: Date) -> Int {
        return ChineseCalendarHelper.dayOfYear(for: date)
    }
    
    // 获取当前是一年中的第几周
    func weekOfYear(for date: Date) -> Int {
        return ChineseCalendarHelper.weekOfYear(for: date)
    }
    
    // 获取当前月份对应的星座
    func zodiacSign(for date: Date) -> String {
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
    

}