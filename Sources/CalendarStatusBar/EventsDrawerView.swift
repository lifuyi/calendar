import SwiftUI
import EventKit
import AppKit

struct EventRowView: View {
    let event: EKEvent
    @EnvironmentObject private var themeManager: ThemeManager
    
    var body: some View {
        HStack {
            // Color dot representing the calendar
            Circle()
                .fill(Color(event.calendar.color ?? .blue))
                .frame(width: 8, height: 8)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(event.title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .lineLimit(1)
                    .foregroundColor(themeManager.currentTheme.textColor)
                
                // Time range
                if let startDate = event.startDate, let endDate = event.endDate {
                    HStack {
                        Text(formatTime(startDate))
                        if !event.isAllDay {
                            Text("-")
                            Text(formatTime(endDate))
                        }
                    }
                    .font(.caption2)
                    .foregroundColor(themeManager.currentTheme.secondaryTextColor)
                }
                
                // Calendar name
                Text(event.calendar.title)
                    .font(.caption2)
                    .foregroundColor(themeManager.currentTheme.secondaryTextColor)
                    .lineLimit(1)
            }
            
            Spacer()
        }
        .padding(.vertical, 2)
        .onTapGesture {
            openEventInCalendarApp(event)
        }
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
    
    private func openEventInCalendarApp(_ event: EKEvent) {
        // Open Calendar app directly using its bundle identifier
        let calendarBundleIdentifier = "com.apple.iCal"
        if let calendarURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: calendarBundleIdentifier) {
            NSWorkspace.shared.openApplication(at: calendarURL, configuration: NSWorkspace.OpenConfiguration())
        }
    }
}

struct EventsDrawerView: View {
    @ObservedObject var eventManager: EventManager
    @Binding var isExpanded: Bool
    @StateObject private var themeManager = ThemeManager.shared
    
    var body: some View {
        VStack(spacing: 0) {
            // Drawer header with toggle button
            HStack {
                Text("今日事件")
                    .font(.headline)
                    .fontWeight(.medium)
                    .foregroundColor(themeManager.currentTheme.textColor)
                
                Spacer()
                
                Button(action: {
                    withAnimation {
                        isExpanded.toggle()
                    }
                }) {
                    Image(systemName: isExpanded ? "chevron.down" : "chevron.up")
                        .font(.caption)
                        .foregroundColor(themeManager.currentTheme.textColor)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(themeManager.currentTheme.gridBackgroundColor)
            .onTapGesture {
                withAnimation {
                    isExpanded.toggle()
                }
            }
            
            // Events list (only shown when expanded)
            if isExpanded {
                // Show authorization error if exists
                if let errorMessage = eventManager.authorizationError {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("权限错误")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(themeManager.currentTheme.holidayColor)
                        
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundColor(themeManager.currentTheme.secondaryTextColor)
                            .fixedSize(horizontal: false, vertical: true)
                        
                        VStack(spacing: 8) {
                            Button("重新请求权限") {
                                eventManager.refreshCalendarAccess()
                            }
                            .font(.caption)
                            .frame(maxWidth: .infinity)
                            .foregroundColor(themeManager.currentTheme.textColor)
                            
                            Button("打开系统设置") {
                                eventManager.openCalendarPrivacySettings()
                            }
                            .font(.caption)
                            .frame(maxWidth: .infinity)
                            .foregroundColor(themeManager.currentTheme.textColor)
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                } else if eventManager.todayEvents.isEmpty {
                    Text("今天没有事件")
                        .font(.caption)
                        .foregroundColor(themeManager.currentTheme.secondaryTextColor)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .frame(minHeight: 50) // Set a minimum height for empty state
                } else {
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 8) {
                            ForEach(eventManager.todayEvents, id: \.eventIdentifier) { event in
                                EventRowView(event: event)
                                    .environmentObject(themeManager)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                    }
                    .frame(maxHeight: 300) // Limit maximum height
                }
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: isExpanded ? 200 : 30, alignment: .top) // Fixed height when expanded
        .animation(.easeInOut, value: isExpanded)
        .background(themeManager.currentTheme.backgroundColor)
        .cornerRadius(8)
        .shadow(radius: 5)
        .padding(.bottom, 20) // 添加底部边距确保可见
    }
}