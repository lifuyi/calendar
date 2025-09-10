import Foundation
import EventKit
import AppKit

@MainActor
class EventManager: ObservableObject {
    static let shared = EventManager()
    
    private(set) var eventStore = EKEventStore()
    @Published var todayEvents: [EKEvent] = []
    @Published var isAuthorized = false
    @Published var authorizationError: String? = nil
    
    private init() {
        requestCalendarAccess()
    }
    
    func requestCalendarAccess() {
        let status = EKEventStore.authorizationStatus(for: .event)
        
        switch status {
        case .authorized:
            isAuthorized = true
            authorizationError = nil
            loadTodayEvents()
        case .notDetermined:
            requestAccess()
        case .denied:
            isAuthorized = false
            authorizationError = "Calendar access denied. Please enable calendar access in System Preferences > Security & Privacy > Privacy > Calendars."
        case .restricted:
            isAuthorized = false
            authorizationError = "Calendar access restricted."
        case .fullAccess:
            isAuthorized = true
            authorizationError = nil
            loadTodayEvents()
        case .writeOnly:
            isAuthorized = false
            authorizationError = "Calendar write-only access granted. Full access is required."
        @unknown default:
            isAuthorized = false
            authorizationError = "Unknown calendar authorization status."
        }
    }
    
    private func requestAccess() {
        // For macOS 14+ (iOS 17+), we need to use the new API
        if #available(macOS 14.0, *) {
            eventStore.requestFullAccessToEvents { [weak self] granted, error in
                DispatchQueue.main.async {
                    if let error = error {
                        self?.authorizationError = "Error requesting calendar access: \(error.localizedDescription)"
                        self?.isAuthorized = false
                        return
                    }
                    
                    self?.isAuthorized = granted
                    if granted {
                        self?.authorizationError = nil
                        self?.loadTodayEvents()
                    } else {
                        self?.authorizationError = "Calendar access denied. The app should now appear in System Preferences > Security & Privacy > Privacy > Calendars. Please enable it there."
                    }
                }
            }
        } else {
            // Fallback for older macOS versions
            eventStore.requestAccess(to: .event) { [weak self] granted, error in
                DispatchQueue.main.async {
                    if let error = error {
                        self?.authorizationError = "Error requesting calendar access: \(error.localizedDescription)"
                        self?.isAuthorized = false
                        return
                    }
                    
                    self?.isAuthorized = granted
                    if granted {
                        self?.authorizationError = nil
                        self?.loadTodayEvents()
                    } else {
                        self?.authorizationError = "Calendar access denied. The app should now appear in System Preferences > Security & Privacy > Privacy > Calendars. Please enable it there."
                    }
                }
            }
        }
    }
    
    func loadTodayEvents() {
        guard isAuthorized else { return }
        
        let today = Date()
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: today)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let predicate = eventStore.predicateForEvents(
            withStart: startOfDay,
            end: endOfDay,
            calendars: nil
        )
        
        let events = eventStore.events(matching: predicate)
        self.todayEvents = events.sorted { $0.startDate < $1.startDate }
    }
    
    func loadEvents(for date: Date) -> [EKEvent] {
        guard isAuthorized else { return [] }
        
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let predicate = eventStore.predicateForEvents(
            withStart: startOfDay,
            end: endOfDay,
            calendars: nil
        )
        
        let events = eventStore.events(matching: predicate)
        return events.sorted { $0.startDate < $1.startDate }
    }
    
    /// Force re-request calendar access
    func refreshCalendarAccess() {
        // Reset state
        isAuthorized = false
        authorizationError = nil
        todayEvents = []
        
        // Always try to request access again, even if previously denied
        requestAccess()
    }
    
    /// Open System Preferences to Calendar privacy settings
    func openCalendarPrivacySettings() {
        // Try multiple URL schemes for different macOS versions
        let urls = [
            "x-apple.systempreferences:com.apple.preference.security?Privacy_Calendars",
            "x-apple.systempreferences:com.apple.preferences.security.privacy?Privacy_Calendars",
            "x-apple.systempreferences:com.apple.preference.security",
            "x-apple.systempreferences:"
        ]
        
        for urlString in urls {
            if let url = URL(string: urlString) {
                let success = NSWorkspace.shared.open(url)
                if success {
                    return
                }
            }
        }
        
        // Fallback: try to open System Preferences app directly
        if let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: "com.apple.systempreferences") {
            NSWorkspace.shared.openApplication(at: url, configuration: NSWorkspace.OpenConfiguration(), completionHandler: nil)
        }
    }
}