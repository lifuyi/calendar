import SwiftUI

struct CompactSettingsView: View {
    @Binding var isPresented: Bool
    @ObservedObject var themeManager = ThemeManager.shared
    private let customFont = "dingliesongtypeface"
    
    var body: some View {
        VStack(spacing: 0) {
            // Header - More compact
            HStack {
                Text("设置")
                    .font(.custom(customFont, size: 18))  // Smaller font
                    .fontWeight(.bold)
                    .foregroundColor(themeManager.currentTheme.textColor)
                
                Spacer()
                
                Button(action: {
                    isPresented = false
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 18))  // Smaller close button
                        .foregroundColor(themeManager.currentTheme.secondaryTextColor)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.horizontal, 16)  // Reduced horizontal padding
            .padding(.vertical, 12)    // Reduced vertical padding
            .background(themeManager.currentTheme.accentColor.opacity(0.1))
            
            ScrollView {
                VStack(spacing: 16) {  // Reduced from 20 to 16 for more compact layout
                    // Theme Selection - More compact
                    SettingsSection(title: "主题选择") {
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 6) {  // 4 columns, reduced spacing
                            ForEach(ThemeType.allCases, id: \.self) { themeType in
                                ThemeSelectionButton(
                                    themeType: themeType,
                                    isSelected: themeManager.currentTheme.type == themeType
                                ) {
                                    print("Setting theme to: \(themeType.displayName)")
                                    themeManager.setTheme(themeType)
                                }
                            }
                        }
                    }
                    
                    Divider()
                        .background(themeManager.currentTheme.secondaryTextColor.opacity(0.3))
                    
                    // Blur Settings
                    SettingsSection(title: "毛玻璃效果") {
                        VStack(spacing: 16) {
                            // Enable/Disable Toggle
                            HStack {
                                Text("启用毛玻璃效果")
                                    .font(.custom(customFont, size: 14))
                                    .foregroundColor(themeManager.currentTheme.textColor)
                                Spacer()
                                Toggle("", isOn: Binding(
                                    get: { themeManager.currentTheme.blurEnabled },
                                    set: { enabled in
                                        print("Toggling blur effect to: \(enabled)")
                                        themeManager.setBlurEffect(enabled: enabled, opacity: themeManager.currentTheme.blurOpacity)
                                    }
                                ))
                                .toggleStyle(SwitchToggleStyle())
                            }
                            
                            if themeManager.currentTheme.blurEnabled {
                                // Blur Direction
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("虚化方向")
                                        .font(.custom(customFont, size: 14))
                                        .fontWeight(.medium)
                                        .foregroundColor(themeManager.currentTheme.textColor)
                                    
                                    HStack(spacing: 12) {
                                        BlurDirectionButton(
                                            title: "前景虚化",
                                            subtitle: "传统方式",
                                            isSelected: !themeManager.currentTheme.blurBackground
                                        ) {
                                            print("Setting blur direction to foreground")
                                            themeManager.setBlurBackground(false)
                                        }
                                        
                                        BlurDirectionButton(
                                            title: "背景虚化",
                                            subtitle: "推荐新功能",
                                            isSelected: themeManager.currentTheme.blurBackground
                                        ) {
                                            print("Setting blur direction to background")
                                            themeManager.setBlurBackground(true)
                                        }
                                    }
                                }
                                
                                // Blur Intensity
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Text("虚化强度")
                                            .font(.custom(customFont, size: 14))
                                            .fontWeight(.medium)
                                            .foregroundColor(themeManager.currentTheme.textColor)
                                        Spacer()
                                        Text("\(Int(themeManager.currentTheme.blurOpacity * 100))%")
                                            .font(.custom(customFont, size: 12))
                                            .foregroundColor(themeManager.currentTheme.accentColor)
                                    }
                                    
                                    Slider(
                                        value: Binding(
                                            get: { themeManager.currentTheme.blurOpacity },
                                            set: { opacity in
                                                themeManager.setBlurEffect(enabled: themeManager.currentTheme.blurEnabled, opacity: opacity)
                                            }
                                        ),
                                        in: 0.1...1.0,
                                        step: 0.05
                                    )
                                    .accentColor(themeManager.currentTheme.accentColor)
                                }
                                
                                // Quick Presets
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("快速预设")
                                        .font(.custom(customFont, size: 14))
                                        .fontWeight(.medium)
                                        .foregroundColor(themeManager.currentTheme.textColor)
                                    
                                    HStack(spacing: 8) {
                                        PresetButton(title: "柔和", subtitle: "60%") {
                                            themeManager.setBlurEffect(enabled: true, opacity: 0.6)
                                            themeManager.setBlurMaterial(.thin)
                                            themeManager.setBlurBackground(true)
                                        }
                                        
                                        PresetButton(title: "标准", subtitle: "80%") {
                                            themeManager.setBlurEffect(enabled: true, opacity: 0.8)
                                            themeManager.setBlurMaterial(.regular)
                                            themeManager.setBlurBackground(true)
                                        }
                                        
                                        PresetButton(title: "强烈", subtitle: "95%") {
                                            themeManager.setBlurEffect(enabled: true, opacity: 0.95)
                                            themeManager.setBlurMaterial(.thick)
                                            themeManager.setBlurBackground(true)
                                        }
                                    }
                                }
                                
                                // Blur Material
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("虚化材质")
                                        .font(.custom(customFont, size: 14))
                                        .fontWeight(.medium)
                                        .foregroundColor(themeManager.currentTheme.textColor)
                                    
                                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 6) {
                                        ForEach(BlurMaterial.allCases, id: \.self) { material in
                                            MaterialButton(
                                                material: material,
                                                isSelected: themeManager.currentTheme.blurMaterial == material
                                            ) {
                                                themeManager.setBlurMaterial(material)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                    Divider()
                        .background(themeManager.currentTheme.secondaryTextColor.opacity(0.3))
                    
                    // Other Settings
                    SettingsSection(title: "其他设置") {
                        VStack(spacing: 12) {
                            LoginItemSettingsRow(
                                icon: "square.and.arrow.up",
                                title: "开机启动",
                                subtitle: "系统启动时自动运行"
                            )
                            
                            SettingsRow(
                                icon: "info.circle",
                                title: "关于应用",
                                subtitle: "版本信息和开源链接"
                            ) {
                                if let url = URL(string: "https://github.com/lifuyi/calendar") {
                                    NSWorkspace.shared.open(url)
                                }
                            }
                            
                            SettingsRow(
                                icon: "arrow.clockwise",
                                title: "检查更新",
                                subtitle: "查看最新版本"
                            ) {
                                if let url = URL(string: "https://github.com/lifuyi/calendar/releases") {
                                    NSWorkspace.shared.open(url)
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 12)  // Reduced from default padding
                .padding(.vertical, 8)     // Reduced from default padding
            }
        }
        .background(themeManager.currentTheme.gridBackgroundColor.opacity(0.95))
    }
}

struct SettingsSection<Content: View>: View {
    let title: String
    let content: Content
    @ObservedObject var themeManager = ThemeManager.shared
    private let customFont = "dingliesongtypeface"
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {  // Reduced from 12 to 8
            Text(title)
                .font(.custom(customFont, size: 14))  // Smaller font
                .fontWeight(.semibold)
                .foregroundColor(themeManager.currentTheme.textColor)
            
            content
        }
    }
}

struct ThemeSelectionButton: View {
    let themeType: ThemeType
    let isSelected: Bool
    let action: () -> Void
    @ObservedObject var themeManager = ThemeManager.shared
    private let customFont = "dingliesongtypeface"
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Circle()
                    .fill(colorForTheme(themeType))
                    .frame(width: 24, height: 24)
                    .overlay(
                        Circle()
                            .stroke(isSelected ? themeManager.currentTheme.accentColor : Color.clear, lineWidth: 2)
                    )
                
                Text(themeType.displayName)
                    .font(.custom(customFont, size: 10))
                    .foregroundColor(themeManager.currentTheme.textColor)
                    .lineLimit(1)
            }
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.vertical, 4)
    }
    
    private func colorForTheme(_ theme: ThemeType) -> Color {
        switch theme {
        case .system: return .gray
        case .light: return .white
        case .dark: return .black
        case .aurora: return Color(red: 0.2, green: 0.8, blue: 0.6)
        case .sunset: return Color(red: 1.0, green: 0.5, blue: 0.3)
        case .ocean: return Color(red: 0.2, green: 0.6, blue: 0.9)
        case .forest: return Color(red: 0.4, green: 0.8, blue: 0.4)
        case .cherryBlossom: return Color(red: 0.9, green: 0.4, blue: 0.7)
        case .lavender: return Color(red: 0.7, green: 0.5, blue: 0.9)
        case .neon: return Color(red: 0.0, green: 1.0, blue: 0.8)
        case .autumn: return Color(red: 0.9, green: 0.6, blue: 0.2)
        case .tropical: return Color(red: 1.0, green: 0.8, blue: 0.0)
        }
    }
}

struct BlurDirectionButton: View {
    let title: String
    let subtitle: String
    let isSelected: Bool
    let action: () -> Void
    @ObservedObject var themeManager = ThemeManager.shared
    private let customFont = "dingliesongtypeface"
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(isSelected ? themeManager.currentTheme.accentColor : themeManager.currentTheme.secondaryTextColor)
                    Text(title)
                        .font(.custom(customFont, size: 12))
                        .fontWeight(.medium)
                        .foregroundColor(themeManager.currentTheme.textColor)
                    Spacer()
                }
                Text(subtitle)
                    .font(.custom(customFont, size: 10))
                    .foregroundColor(themeManager.currentTheme.secondaryTextColor)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .background(
                isSelected ? 
                themeManager.currentTheme.accentColor.opacity(0.1) : 
                themeManager.currentTheme.gridBackgroundColor.opacity(0.5)
            )
            .cornerRadius(8)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct PresetButton: View {
    let title: String
    let subtitle: String
    let action: () -> Void
    @ObservedObject var themeManager = ThemeManager.shared
    private let customFont = "dingliesongtypeface"
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 2) {
                Text(title)
                    .font(.custom(customFont, size: 12))
                    .fontWeight(.medium)
                    .foregroundColor(themeManager.currentTheme.textColor)
                Text(subtitle)
                    .font(.custom(customFont, size: 10))
                    .foregroundColor(themeManager.currentTheme.secondaryTextColor)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(themeManager.currentTheme.accentColor.opacity(0.2))
            .cornerRadius(6)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct MaterialButton: View {
    let material: BlurMaterial
    let isSelected: Bool
    let action: () -> Void
    @ObservedObject var themeManager = ThemeManager.shared
    private let customFont = "dingliesongtypeface"
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? themeManager.currentTheme.accentColor : themeManager.currentTheme.secondaryTextColor)
                Text(material.displayName)
                    .font(.custom(customFont, size: 11))
                    .foregroundColor(themeManager.currentTheme.textColor)
                Spacer()
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                isSelected ? 
                themeManager.currentTheme.accentColor.opacity(0.1) : 
                Color.clear
            )
            .cornerRadius(4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct SettingsRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let action: () -> Void
    @ObservedObject var themeManager = ThemeManager.shared
    private let customFont = "dingliesongtypeface"
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(themeManager.currentTheme.accentColor)
                    .frame(width: 20)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.custom(customFont, size: 14))
                        .fontWeight(.medium)
                        .foregroundColor(themeManager.currentTheme.textColor)
                    Text(subtitle)
                        .font(.custom(customFont, size: 11))
                        .foregroundColor(themeManager.currentTheme.secondaryTextColor)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 12))
                    .foregroundColor(themeManager.currentTheme.secondaryTextColor)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct LoginItemSettingsRow: View {
    let icon: String
    let title: String
    let subtitle: String
    @ObservedObject var themeManager = ThemeManager.shared
    private let customFont = "dingliesongtypeface"
    @State private var isEnabled: Bool = false
    
    var body: some View {
        Button(action: toggleLoginItem) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(themeManager.currentTheme.accentColor)
                    .frame(width: 20)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.custom(customFont, size: 14))
                        .fontWeight(.medium)
                        .foregroundColor(themeManager.currentTheme.textColor)
                    Text(subtitle)
                        .font(.custom(customFont, size: 11))
                        .foregroundColor(themeManager.currentTheme.secondaryTextColor)
                }
                
                Spacer()
                
                // Checkbox to show current state
                Image(systemName: isEnabled ? "checkmark.square.fill" : "square")
                    .font(.system(size: 16))
                    .foregroundColor(isEnabled ? themeManager.currentTheme.accentColor : themeManager.currentTheme.secondaryTextColor)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
        }
        .buttonStyle(PlainButtonStyle())
        .onAppear {
            updateLoginItemState()
        }
    }
    
    private func toggleLoginItem() {
        if let appDelegate = NSApp.delegate as? AppDelegate {
            appDelegate.perform(#selector(AppDelegate.toggleLoginItem(_:)), with: nil)
            // Update the state after a short delay to allow the toggle to complete
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                updateLoginItemState()
            }
        }
    }
    
    private func updateLoginItemState() {
        if let appDelegate = NSApp.delegate as? AppDelegate {
            isEnabled = appDelegate.isLoginItemEnabled()
        }
    }
}

struct CompactSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        CompactSettingsView(isPresented: .constant(true))
            .frame(width: 400, height: 500)
    }
}