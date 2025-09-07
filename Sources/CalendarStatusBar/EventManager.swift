import Foundation
import EventKit
import AppKit

@MainActor
class EventManager: ObservableObject {
    static let shared = EventManager()
    
    private var eventStore = EKEventStore()
    @Published var todayEvents: [EKEvent] = []
    @Published var isAuthorized = false
    @Published var authorizationError: String? = nil
    
    private init() {
        requestCalendarAccess()
    }
    
    func requestCalendarAccess() {
        print("Checking calendar authorization status...")
        let status = EKEventStore.authorizationStatus(for: .event)
        print("Current authorization status: \(status.rawValue)")
        
        switch status {
        case .authorized:
            print("Calendar access already authorized")
            isAuthorized = true
            authorizationError = nil
            loadTodayEvents()
        case .notDetermined:
            print("Calendar access not determined, requesting access...")
            requestAccess()
        case .denied:
            print("Calendar access denied")
            isAuthorized = false
            authorizationError = "Calendar access denied. Please enable calendar access in System Preferences > Security & Privacy > Privacy > Calendars."
        case .restricted:
            print("Calendar access restricted")
            isAuthorized = false
            authorizationError = "Calendar access restricted."
        case .fullAccess:
            print("Calendar full access granted")
            isAuthorized = true
            authorizationError = nil
            loadTodayEvents()
        case .writeOnly:
            print("Calendar write-only access")
            isAuthorized = false
            authorizationError = "Calendar write-only access granted. Full access is required."
        @unknown default:
            print("Unknown calendar authorization status")
            isAuthorized = false
            authorizationError = "Unknown calendar authorization status."
        }
    }
    
    private func requestAccess() {
        print("Requesting calendar access...")
        print("App bundle identifier: \(Bundle.main.bundleIdentifier ?? "none")")
        print("App executable name: \(Bundle.main.executableURL?.lastPathComponent ?? "none")")
        
        // Force the app to appear in privacy settings by making a calendar request
        // This will trigger the system to add the app to the privacy list
        
        // For macOS 14+ (iOS 17+), we need to use the new API
        if #available(macOS 14.0, *) {
            eventStore.requestFullAccessToEvents { [weak self] granted, error in
                DispatchQueue.main.async {
                    if let error = error {
                        self?.authorizationError = "Error requesting calendar access: \(error.localizedDescription)"
                        self?.isAuthorized = false
                        print("Calendar access error: \(error.localizedDescription)")
                        return
                    }
                    
                    self?.isAuthorized = granted
                    if granted {
                        print("Calendar access granted")
                        self?.authorizationError = nil
                        self?.loadTodayEvents()
                    } else {
                        print("Calendar access denied")
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
                        print("Calendar access error: \(error.localizedDescription)")
                        return
                    }
                    
                    self?.isAuthorized = granted
                    if granted {
                        print("Calendar access granted")
                        self?.authorizationError = nil
                        self?.loadTodayEvents()
                    } else {
                        print("Calendar access denied")
                        self?.authorizationError = "Calendar access denied. The app should now appear in System Preferences > Security & Privacy > Privacy > Calendars. Please enable it there."
                    }
                }
            }
        }
    }
    
    func loadTodayEvents() {
        print("loadTodayEvents called, isAuthorized: \(isAuthorized)")
        guard isAuthorized else { 
            print("Not authorized, skipping event loading")
            return 
        }
        
        let today = Date()
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: today)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        print("Loading events from \(startOfDay) to \(endOfDay)")
        
        let predicate = eventStore.predicateForEvents(
            withStart: startOfDay,
            end: endOfDay,
            calendars: nil
        )
        
        let events = eventStore.events(matching: predicate)
        print("Found \(events.count) events")
        
        for event in events {
            print("Event: \(event.title ?? "No title") at \(event.startDate ?? Date())")
        }
        
        self.todayEvents = events.sorted { $0.startDate < $1.startDate }
        print("todayEvents updated with \(self.todayEvents.count) events")
    }
    
    /// Force re-request calendar access
    func refreshCalendarAccess() {
        print("Refreshing calendar access...")
        // Reset state
        isAuthorized = false
        authorizationError = nil
        todayEvents = []
        
        // Always try to request access again, even if previously denied
        requestAccess()
    }
    
    /// Open System Preferences to Calendar privacy settings
    func openCalendarPrivacySettings() {
        print("Attempting to open Calendar privacy settings...")
        
        // Try multiple URL schemes for different macOS versions
        let urls = [
            "x-apple.systempreferences:com.apple.preference.security?Privacy_Calendars", // macOS 12 and earlier
            "x-apple.systempreferences:com.apple.preferences.security.privacy?Privacy_Calendars", // Alternative
            "x-apple.systempreferences:com.apple.preference.security", // Just security pane
            "x-apple.systempreferences:" // Just open System Preferences
        ]
        
        for urlString in urls {
            if let url = URL(string: urlString) {
                print("Trying URL: \(urlString)")
                let success = NSWorkspace.shared.open(url)
                if success {
                    print("Successfully opened: \(urlString)")
                    return
                } else {
                    print("Failed to open: \(urlString)")
                }
            }
        }
        
        // Fallback: try to open System Preferences app directly
        print("Fallback: Opening System Preferences app directly")
        let success = NSWorkspace.shared.launchApplication("System Preferences")
        if success {
            print("Successfully opened System Preferences app")
        } else {
            print("Failed to open System Preferences app")
        }
    }
}