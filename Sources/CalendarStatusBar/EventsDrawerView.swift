import SwiftUI
import EventKit

struct EventsDrawerView: View {
    @ObservedObject var eventManager: EventManager
    @Binding var isExpanded: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            // Drawer header with toggle button
            HStack {
                Text("今日事件")
                    .font(.headline)
                    .fontWeight(.medium)
                
                Spacer()
                
                Button(action: {
                    withAnimation {
                        isExpanded.toggle()
                    }
                }) {
                    Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                        .font(.caption)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(Color.gray.opacity(0.2))
            
            // Events list (only shown when expanded)
            if isExpanded {
                // Show authorization error if exists
                if let errorMessage = eventManager.authorizationError {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("权限错误")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.red)
                        
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                        
                        VStack(spacing: 8) {
                            Button("重新请求权限") {
                                print("Re-request permission button clicked!")
                                eventManager.refreshCalendarAccess()
                            }
                            .font(.caption)
                            .frame(maxWidth: .infinity)
                            
                            Button("打开系统设置") {
                                print("Open System Settings button clicked!")
                                eventManager.openCalendarPrivacySettings()
                            }
                            .font(.caption)
                            .frame(maxWidth: .infinity)
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                } else if eventManager.todayEvents.isEmpty {
                    Text("今天没有事件")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding()
                        .frame(maxWidth: .infinity)
                } else {
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 8) {
                            ForEach(eventManager.todayEvents, id: \.eventIdentifier) { event in
                                EventRowView(event: event)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                    }
                }
            }
        }
        .frame(maxHeight: isExpanded ? 200 : nil)
    }
}

struct EventRowView: View {
    let event: EKEvent
    
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
                    .foregroundColor(.secondary)
                }
                
                // Calendar name
                Text(event.calendar.title)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            
            Spacer()
        }
        .padding(.vertical, 2)
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}