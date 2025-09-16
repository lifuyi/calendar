import Foundation

// 日期信息结构
struct DayInfo: Identifiable {
    let id = UUID()
    let date: Date
    let isCurrentMonth: Bool
}