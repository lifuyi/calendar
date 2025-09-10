import SwiftUI
import EventKit

struct EventCreationView: View {
    @Binding var isPresented: Bool
    let selectedDate: Date
    @StateObject private var eventManager = EventManager.shared
    @StateObject private var themeManager = ThemeManager.shared
    
    // Event properties
    @State private var title = ""
    @State private var eventType = "任务"
    @State private var startTime = Date()
    @State private var duration = 15 // in minutes
    @State private var description = ""
    @State private var tags = ""
    
    // Event types
    let eventTypes = ["任务", "会议", "提醒", "约会"]
    
    // Duration options
    let durationOptions = [
        (15, "15分钟"),
        (30, "30分钟"),
        (60, "1小时"),
        (120, "2小时"),
        (180, "3小时"),
        (240, "4小时"),
        (480, "8小时"),
        (1440, "1天")
    ]
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter.string(from: selectedDate)
    }
    
    private var formattedDateTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/M/d HH:mm"
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter.string(from: startTime)
    }
    
    var body: some View {
        VStack(spacing: 15) {
            // Header with date
            HStack {
                Text(formattedDate)
                    .font(.headline)
                    .foregroundColor(themeManager.currentTheme.textColor)
                Spacer()
            }
            .padding(.horizontal)
            
            // Title input
            VStack(alignment: .leading, spacing: 5) {
                Text("标题")
                    .font(.caption)
                    .foregroundColor(themeManager.currentTheme.secondaryTextColor)
                TextField("输入标题", text: $title)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .font(.system(size: 14))
            }
            .padding(.horizontal)
            
            // Event type selection
            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    Text("任务类型")
                        .font(.caption)
                        .foregroundColor(themeManager.currentTheme.secondaryTextColor)
                    Picker("任务类型", selection: $eventType) {
                        ForEach(eventTypes, id: \.self) { type in
                            Text(type).tag(type)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .frame(height: 30)
                }
                
                Spacer()
            }
            .padding(.horizontal)
            
            // Start time and duration
            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    Text("开始时间")
                        .font(.caption)
                        .foregroundColor(themeManager.currentTheme.secondaryTextColor)
                    DatePicker("", selection: $startTime, displayedComponents: [.date, .hourAndMinute])
                        .datePickerStyle(CompactDatePickerStyle())
                        .frame(height: 30)
                }
                
                Spacer()
                
                VStack(alignment: .leading, spacing: 5) {
                    Text("需要时间")
                        .font(.caption)
                        .foregroundColor(themeManager.currentTheme.secondaryTextColor)
                    Picker("需要时间", selection: $duration) {
                        ForEach(durationOptions, id: \.0) { option in
                            Text(option.1).tag(option.0)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .frame(height: 30)
                }
            }
            .padding(.horizontal)
            
            // Description
            VStack(alignment: .leading, spacing: 5) {
                Text("描述")
                    .font(.caption)
                    .foregroundColor(themeManager.currentTheme.secondaryTextColor)
                TextEditor(text: $description)
                    .frame(height: 80)
                    .overlay(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                    .font(.system(size: 14))
            }
            .padding(.horizontal)
            
            // Tags
            VStack(alignment: .leading, spacing: 5) {
                Text("标签")
                    .font(.caption)
                    .foregroundColor(themeManager.currentTheme.secondaryTextColor)
                TextField("标签,多个用逗号隔开", text: $tags)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .font(.system(size: 14))
            }
            .padding(.horizontal)
            
            // Save button
            Button(action: saveEvent) {
                Text("保存")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(themeManager.currentTheme.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding(.horizontal)
            .disabled(title.isEmpty || !eventManager.isAuthorized)
            .opacity(title.isEmpty || !eventManager.isAuthorized ? 0.6 : 1.0)
        }
        .padding(.vertical, 20)
        .background(themeManager.currentTheme.backgroundColor)
        .onAppear {
            // Set default start time to the selected date at 9:00 AM
            let calendar = Calendar.current
            var components = calendar.dateComponents([.year, .month, .day], from: selectedDate)
            components.hour = 9
            components.minute = 0
            startTime = calendar.date(from: components) ?? selectedDate
        }
    }
    
    private func saveEvent() {
        guard eventManager.isAuthorized else {
            // Show error message
            return
        }
        
        // Create the event using EventKit
        let event = EKEvent(eventStore: eventManager.eventStore)
        event.title = title
        event.startDate = startTime
        
        // Calculate end time based on duration
        let calendar = Calendar.current
        let endDate = calendar.date(byAdding: .minute, value: duration, to: startTime) ?? startTime
        event.endDate = endDate
        
        event.notes = description
        
        // Add tags as notes if any
        if !tags.isEmpty {
            event.notes = (event.notes ?? "") + "\n\n标签: \(tags)"
        }
        
        // Use default calendar
        event.calendar = eventManager.eventStore.defaultCalendarForNewEvents
        
        do {
            try eventManager.eventStore.save(event, span: .thisEvent)
            // Refresh events
            eventManager.loadTodayEvents()
            // Close the popup
            isPresented = false
        } catch {
            print("Failed to save event: \(error)")
            // Show error message to user
        }
    }
}