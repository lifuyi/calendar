import SwiftUI

struct AdvancedSettingsView: View {
    @ObservedObject var themeManager: ThemeManager
    @State private var showingBlurSettings = false
    private let customFont = "dingliesongtypeface"
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("高级设置")
                .font(.custom(customFont, size: 24))
                .fontWeight(.bold)
                .foregroundColor(themeManager.currentTheme.textColor)
            
            // 毛玻璃效果设置区域
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("视觉效果")
                        .font(.custom(customFont, size: 18))
                        .fontWeight(.semibold)
                        .foregroundColor(themeManager.currentTheme.textColor)
                    
                    Spacer()
                    
                    Button(action: {
                        showingBlurSettings.toggle()
                    }) {
                        HStack {
                            Text(showingBlurSettings ? "收起" : "展开")
                                .font(.custom(customFont, size: 14))
                            Image(systemName: showingBlurSettings ? "chevron.up" : "chevron.down")
                        }
                        .foregroundColor(themeManager.currentTheme.accentColor)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                
                // 快速效果预览
                HStack(spacing: 12) {
                    VStack {
                        Text("当前效果")
                            .font(.custom(customFont, size: 12))
                            .foregroundColor(themeManager.currentTheme.secondaryTextColor)
                        
                        BlurPreviewCard(
                            title: themeManager.currentTheme.blurEnabled ? 
                                (themeManager.currentTheme.blurBackground ? "背景虚化" : "前景虚化") : 
                                "无效果",
                            intensity: themeManager.currentTheme.blurOpacity,
                            material: themeManager.currentTheme.blurMaterial.displayName,
                            isActive: themeManager.currentTheme.blurEnabled,
                            themeManager: themeManager
                        )
                    }
                    
                    Spacer()
                    
                    VStack(spacing: 8) {
                        Button("快速启用") {
                            themeManager.setBlurEffect(enabled: true, opacity: 0.8)
                            themeManager.setBlurBackground(true)
                            themeManager.setBlurMaterial(.regular)
                        }
                        .font(.custom(customFont, size: 12))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(themeManager.currentTheme.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        
                        Button("关闭效果") {
                            themeManager.setBlurEffect(enabled: false, opacity: 0)
                        }
                        .font(.custom(customFont, size: 12))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.gray.opacity(0.3))
                        .foregroundColor(themeManager.currentTheme.textColor)
                        .cornerRadius(8)
                    }
                }
                
                if showingBlurSettings {
                    BlurSettingsView(themeManager: themeManager)
                        .transition(.opacity.combined(with: .scale))
                }
            }
            .padding()
            .background(
                themeManager.currentTheme.blurEnabled && themeManager.currentTheme.blurBackground ?
                AnyView(
                    OptimizedBlurEffect(
                        material: .menu,
                        opacity: 0.6,
                        blurBackground: true,
                        intensity: .subtle
                    )
                ) :
                AnyView(themeManager.currentTheme.gridBackgroundColor.opacity(0.8))
            )
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(themeManager.currentTheme.accentColor.opacity(0.3), lineWidth: 1)
            )
            
            Spacer()
        }
        .padding()
        .animation(.easeInOut(duration: 0.3), value: showingBlurSettings)
    }
}

struct BlurPreviewCard: View {
    let title: String
    let intensity: Double
    let material: String
    let isActive: Bool
    @ObservedObject var themeManager: ThemeManager
    private let customFont = "dingliesongtypeface"
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.custom(customFont, size: 14))
                .fontWeight(.medium)
                .foregroundColor(isActive ? themeManager.currentTheme.accentColor : themeManager.currentTheme.secondaryTextColor)
            
            if isActive {
                Text("强度: \(Int(intensity * 100))%")
                    .font(.custom(customFont, size: 11))
                    .foregroundColor(themeManager.currentTheme.secondaryTextColor)
                
                Text("材质: \(material)")
                    .font(.custom(customFont, size: 11))
                    .foregroundColor(themeManager.currentTheme.secondaryTextColor)
            } else {
                Text("未启用毛玻璃效果")
                    .font(.custom(customFont, size: 11))
                    .foregroundColor(themeManager.currentTheme.secondaryTextColor)
            }
        }
        .padding(12)
        .frame(width: 120, height: 80)
        .background(
            isActive && themeManager.currentTheme.blurEnabled ?
            AnyView(
                themeManager.currentTheme.blurBackground ?
                AnyView(OptimizedBlurEffect(
                    material: themeManager.currentTheme.blurMaterial.nsMaterial,
                    opacity: themeManager.currentTheme.blurOpacity * 0.7,
                    blurBackground: true,
                    intensity: .subtle
                )) :
                AnyView(VisualEffectBlur(
                    material: themeManager.currentTheme.blurMaterial.nsMaterial,
                    blendingMode: .withinWindow,
                    opacity: themeManager.currentTheme.blurOpacity * 0.7
                ))
            ) :
            AnyView(themeManager.currentTheme.gridBackgroundColor.opacity(0.5))
        )
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(
                    isActive ? themeManager.currentTheme.accentColor.opacity(0.5) : Color.gray.opacity(0.3),
                    lineWidth: 1
                )
        )
    }
}

struct AdvancedSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        AdvancedSettingsView(themeManager: ThemeManager.shared)
            .frame(width: 500, height: 700)
            .background(Color.black.opacity(0.1))
    }
}