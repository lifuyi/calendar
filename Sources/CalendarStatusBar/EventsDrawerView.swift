import SwiftUI
import EventKit

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
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(Color.gray.opacity(0.2))
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
                            .foregroundColor(.red)
                        
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                        
                        VStack(spacing: 8) {
                            Button("重新请求权限") {
                                eventManager.refreshCalendarAccess()
                            }
                            .font(.caption)
                            .frame(maxWidth: .infinity)
                            
                            Button("打开系统设置") {
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
                        .frame(minHeight: 50) // Set a minimum height for empty state
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
                    .frame(maxHeight: 300) // Limit maximum height
                }
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: isExpanded ? 200 : 30, alignment: .top) // Fixed height when expanded
        .animation(.easeInOut, value: isExpanded)
        .background(Color(NSColor.windowBackgroundColor))
        .cornerRadius(8)
        .shadow(radius: 5)
        .padding(.bottom, 20) // 添加底部边距确保可见
    }
}