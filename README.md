# CalendarStatusBar

A comprehensive macOS status bar calendar application that provides quick access to calendar information, weather updates, and event management directly from your menu bar.

## ✨ Features

### 📅 Calendar & Date Information
- **Real-time status bar display**: Shows current date and time (format: MM月dd日 HH:mm E)
- **Interactive calendar view**: Click the status bar to expand a full calendar interface
- **Extensive date range**: Support for years 1900-2075
- **Lunar calendar support**: Display Chinese lunar dates alongside Gregorian calendar
- **Chinese holidays & solar terms**: Automatically marks Chinese legal holidays and traditional solar terms
- **Quick navigation**: Easy month/year switching with "return to today" functionality

### 🌤️ Weather Integration
- **Current weather conditions**: Temperature, weather status, humidity, and atmospheric pressure
- **Precipitation data**: Real-time rainfall information
- **Feels-like temperature**: Apparent temperature based on weather conditions
- **Location-based updates**: Automatic weather updates based on your location

### 📝 Event Management
- **Calendar integration**: View today's events directly in the status bar interface
- **Quick event creation**: Double-click any date to create new calendar events
- **Event browsing**: Single-click dates to view all events for that day
- **Native app integration**: Click events to open them in macOS Calendar app
- **Permission handling**: Seamless calendar access authorization with helpful error messages

### 🎨 Visual Customization
- **Blur effects**: Configurable glass morphism effects for the interface
- **Transparency control**: Adjustable opacity levels (20%, 40%, 60%, 80%, 100%, 120%, 150%)
- **Responsive design**: Clean, modern interface that adapts to system themes
- **Smooth animations**: Polished transitions and interactions

### 🔧 Technical Features
- **Background updates**: Periodic refresh of weather and calendar data
- **Efficient resource usage**: Optimized for minimal system impact
- **Privacy-focused**: All data processing happens locally
- **Error handling**: Comprehensive error management and user feedback

## 🖥️ System Requirements

- **macOS**: 12.0 (Monterey) or later
- **Development**: Xcode 13.0 or later (for building from source)
- **Architecture**: Universal binary (Intel & Apple Silicon)

## 🚀 Installation & Setup

### Method 1: Pre-built Application
1. Download the latest release from the [Releases](link-to-releases) page
2. Open the downloaded `.dmg` file
3. Drag `CalendarStatusBar.app` to your Applications folder
4. Launch the app from Applications or Spotlight

### Method 2: Build from Source

#### Command Line Build
```bash
# Clone the repository
git clone https://github.com/your-username/CalendarStatusBar.git
cd CalendarStatusBar

# Build the project
swift build -c release

# Run the application
swift run
```

#### Xcode Build
1. Open Xcode
2. Select "Open a project or file"
3. Navigate to the project directory and select `Package.swift`
4. Click "Open"
5. Select your target device/simulator
6. Press `Cmd+R` to build and run

### Method 3: Create Application Bundle
```bash
# Use the provided script to create a standalone app
./create_app_bundle.sh

# Create a distributable DMG
./create_dmg_final.sh
```

## 📖 Usage Guide

### First Launch
1. **Calendar Permissions**: The app will request access to your calendar data
   - Click "Allow" when prompted
   - If denied, use the settings to re-request permissions
   - Manual setup: System Preferences > Security & Privacy > Privacy > Calendars

2. **Location Services**: For weather features, enable location access when prompted

### Daily Usage
- **View Calendar**: Click the status bar icon to open the calendar interface
- **Navigate Dates**: Use arrow buttons or date selectors to browse different months/years
- **Create Events**: Double-click any date to quickly create a new calendar event
- **View Events**: Single-click dates to see existing events for that day
- **Weather Info**: Weather data updates automatically and displays in the interface

### Customization
- **Blur Effects**: Access settings to enable/disable glass morphism effects
- **Transparency**: Adjust interface opacity to match your preference
- **Auto-launch**: Configure the app to start automatically when you log in

### Troubleshooting
- **Calendar not showing**: Check calendar permissions in System Preferences
- **Weather not updating**: Verify location services are enabled
- **App not starting**: Ensure macOS version compatibility (12.0+)

## 🛠️ Development

### Project Structure
```
CalendarStatusBar/
├── Sources/CalendarStatusBar/
│   ├── App.swift                    # Main application entry point
│   ├── CalendarView.swift           # Primary calendar interface
│   ├── CalendarViewModel.swift      # Calendar business logic
│   ├── EventManager.swift           # Calendar event handling
│   ├── WeatherService.swift         # Weather data integration
│   ├── ChineseCalendarHelper.swift  # Lunar calendar calculations
│   ├── HolidayManager.swift         # Holiday and solar term data
│   ├── ThemeManager.swift           # Visual theming system
│   ├── BlurEffect components/       # Visual effects
│   └── assets/                      # App icons and resources
├── Package.swift                    # Swift Package Manager configuration
└── Scripts/                         # Build and distribution scripts
```

### Key Dependencies
- **SwiftUI**: Modern declarative UI framework
- **EventKit**: macOS calendar integration
- **CoreLocation**: Location services for weather
- **Foundation**: Core utilities and networking

### Contributing
1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 🗺️ Roadmap

### Planned Features
- [ ] **Custom Themes**: Additional color schemes and visual styles
- [ ] **Event Notifications**: Configurable reminders and alerts
- [ ] **Multi-calendar Support**: Better integration with multiple calendar accounts
- [ ] **Keyboard Shortcuts**: Quick access hotkeys
- [ ] **Export Functionality**: Save calendar views as images
- [ ] **Widgets**: Additional display modes and layouts

### Long-term Goals
- [ ] **Internationalization**: Support for multiple languages
- [ ] **Plugin System**: Extensible architecture for third-party additions
- [ ] **Cloud Sync**: Optional settings synchronization across devices

## 🤝 Support

### Getting Help
- **Issues**: Report bugs or request features via GitHub Issues
- **Documentation**: Check the wiki for detailed guides
- **Community**: Join discussions in GitHub Discussions

### Known Issues
- Weather data may take a few seconds to load on first launch
- Some calendar permissions may require app restart to take effect

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Weather data provided by Open-Meteo API
- Chinese calendar calculations based on traditional astronomical algorithms
- Holiday data sourced from official Chinese government calendars
- Icons and visual assets designed specifically for this application

---

**Made with ❤️ for macOS users who love staying organized**