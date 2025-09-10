import SwiftUI
import EventKit
import AppKit

struct EventListView: View {
    let date: Date
    let events: [EKEvent]
    @Binding var isPresented: Bool
    @StateObject private var themeManager = ThemeManager.shared
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年MM月dd日 EEEE"
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter.string(from: date)
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter.string(from: date)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text(formattedDate)
                    .font(.headline)
                    .foregroundColor(themeManager.currentTheme.textColor)
                Spacer()
                Button(action: {
                    isPresented = false
                }) {
                    Image(systemName: "xmark")
                        .foregroundColor(themeManager.currentTheme.textColor)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding()
            .background(themeManager.currentTheme.gridBackgroundColor)
            
            // Events list
            if events.isEmpty {
                VStack {
                    Image(systemName: "calendar.badge.exclamationmark")
                        .font(.largeTitle)
                        .foregroundColor(themeManager.currentTheme.secondaryTextColor)
                        .padding(.bottom, 8)
                    Text("这一天没有事件")
                        .foregroundColor(themeManager.currentTheme.secondaryTextColor)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 10) {
                        ForEach(events, id: \.eventIdentifier) { event in
                            EventItemView(event: event)
                        }
                    }
                    .padding()
                }
            }
            
            // Add event button
            Button(action: {
                NotificationCenter.default.post(name: .showEventCreationPopup, object: date)
                isPresented = false
            }) {
                Text("添加事件")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(themeManager.currentTheme.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding()
        }
        .frame(width: 300, height: 400)
        .background(themeManager.currentTheme.backgroundColor)
        .cornerRadius(10)
        .shadow(radius: 10)
    }
}

struct EventItemView: View {
    let event: EKEvent
    @StateObject private var themeManager = ThemeManager.shared
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter.string(from: date)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                // Time range
                VStack(alignment: .trailing, spacing: 2) {
                    Text(formatTime(event.startDate))
                        .font(.caption)
                        .foregroundColor(themeManager.currentTheme.secondaryTextColor)
                    Text(formatTime(event.endDate))
                        .font(.caption)
                        .foregroundColor(themeManager.currentTheme.secondaryTextColor)
                }
                .frame(width: 50)
                
                // Event details
                VStack(alignment: .leading, spacing: 2) {
                    Text(event.title)
                        .font(.body)
                        .foregroundColor(themeManager.currentTheme.textColor)
                        .lineLimit(2)
                    
                    if let location = event.location, !location.isEmpty {
                        Text(location)
                            .font(.caption)
                            .foregroundColor(themeManager.currentTheme.secondaryTextColor)
                            .lineLimit(1)
                    }
                    
                    if let notes = event.notes, !notes.isEmpty {
                        Text(notes)
                            .font(.caption)
                            .foregroundColor(themeManager.currentTheme.secondaryTextColor)
                            .lineLimit(2)
                    }
                }
                
                Spacer()
            }
            
            // Calendar name
            if let calendar = event.calendar {
                HStack {
                    Circle()
                        .fill(Color(calendar.cgColor ?? NSColor.systemBlue.cgColor))
                        .frame(width: 8, height: 8)
                    Text(calendar.title)
                        .font(.caption)
                        .foregroundColor(themeManager.currentTheme.secondaryTextColor)
                    Spacer()
                }
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(themeManager.currentTheme.gridBackgroundColor)
        .cornerRadius(6)
    }
}