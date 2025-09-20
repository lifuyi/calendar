import SwiftUI

struct BlurSettingsView: View {
    @ObservedObject var themeManager: ThemeManager
    private let customFont = "dingliesongtypeface"
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("毛玻璃效果设置")
                .font(.custom(customFont, size: 18))
                .fontWeight(.bold)
                .foregroundColor(themeManager.currentTheme.textColor)
            
            // 启用/禁用毛玻璃效果
            HStack {
                Toggle("启用毛玻璃效果", isOn: Binding(
                    get: { themeManager.currentTheme.blurEnabled },
                    set: { enabled in
                        themeManager.setBlurEffect(enabled: enabled, opacity: themeManager.currentTheme.blurOpacity)
                    }
                ))
                .font(.custom(customFont, size: 14))
                .foregroundColor(themeManager.currentTheme.textColor)
            }
            
            if themeManager.currentTheme.blurEnabled {
                Divider()
                    .background(themeManager.currentTheme.secondaryTextColor)
                
                // 虚化方向选择
                VStack(alignment: .leading, spacing: 8) {
                    Text("虚化方向")
                        .font(.custom(customFont, size: 16))
                        .fontWeight(.medium)
                        .foregroundColor(themeManager.currentTheme.textColor)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Button(action: {
                                themeManager.setBlurBackground(false)
                            }) {
                                HStack {
                                    Image(systemName: themeManager.currentTheme.blurBackground ? "circle" : "circle.fill")
                                        .foregroundColor(themeManager.currentTheme.accentColor)
                                    Text("前景虚化")
                                        .font(.custom(customFont, size: 14))
                                        .foregroundColor(themeManager.currentTheme.textColor)
                                    Spacer()
                                }
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        
                        Text("在内容上方添加毛玻璃效果（传统方式）")
                            .font(.custom(customFont, size: 12))
                            .foregroundColor(themeManager.currentTheme.secondaryTextColor)
                            .padding(.leading, 20)
                        
                        HStack {
                            Button(action: {
                                themeManager.setBlurBackground(true)
                            }) {
                                HStack {
                                    Image(systemName: themeManager.currentTheme.blurBackground ? "circle.fill" : "circle")
                                        .foregroundColor(themeManager.currentTheme.accentColor)
                                    Text("背景虚化")
                                        .font(.custom(customFont, size: 14))
                                        .foregroundColor(themeManager.currentTheme.textColor)
                                    Spacer()
                                }
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        
                        Text("对底层背景进行虚化处理（推荐）")
                            .font(.custom(customFont, size: 12))
                            .foregroundColor(themeManager.currentTheme.secondaryTextColor)
                            .padding(.leading, 20)
                    }
                }
                
                Divider()
                    .background(themeManager.currentTheme.secondaryTextColor)
                
                // 透明度调节
                VStack(alignment: .leading, spacing: 8) {
                    Text("虚化强度: \(Int(themeManager.currentTheme.blurOpacity * 100))%")
                        .font(.custom(customFont, size: 16))
                        .fontWeight(.medium)
                        .foregroundColor(themeManager.currentTheme.textColor)
                    
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
                
                Divider()
                    .background(themeManager.currentTheme.secondaryTextColor)
                
                // 材质选择
                VStack(alignment: .leading, spacing: 8) {
                    Text("虚化材质")
                        .font(.custom(customFont, size: 16))
                        .fontWeight(.medium)
                        .foregroundColor(themeManager.currentTheme.textColor)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 8) {
                        ForEach(BlurMaterial.allCases, id: \.self) { material in
                            Button(action: {
                                themeManager.setBlurMaterial(material)
                            }) {
                                HStack {
                                    Image(systemName: themeManager.currentTheme.blurMaterial == material ? "checkmark.circle.fill" : "circle")
                                        .foregroundColor(themeManager.currentTheme.accentColor)
                                    Text(material.displayName)
                                        .font(.custom(customFont, size: 12))
                                        .foregroundColor(themeManager.currentTheme.textColor)
                                    Spacer()
                                }
                                .padding(.vertical, 4)
                                .padding(.horizontal, 8)
                                .background(
                                    themeManager.currentTheme.blurMaterial == material ? 
                                    themeManager.currentTheme.accentColor.opacity(0.1) : 
                                    Color.clear
                                )
                                .cornerRadius(6)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
                
                Divider()
                    .background(themeManager.currentTheme.secondaryTextColor)
                
                // 预设效果
                VStack(alignment: .leading, spacing: 8) {
                    Text("快速预设")
                        .font(.custom(customFont, size: 16))
                        .fontWeight(.medium)
                        .foregroundColor(themeManager.currentTheme.textColor)
                    
                    HStack(spacing: 12) {
                        Button("柔和") {
                            themeManager.setBlurEffect(enabled: true, opacity: 0.6)
                            themeManager.setBlurMaterial(.thin)
                            themeManager.setBlurBackground(true)
                        }
                        .font(.custom(customFont, size: 12))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(themeManager.currentTheme.accentColor.opacity(0.2))
                        .foregroundColor(themeManager.currentTheme.textColor)
                        .cornerRadius(6)
                        
                        Button("标准") {
                            themeManager.setBlurEffect(enabled: true, opacity: 0.8)
                            themeManager.setBlurMaterial(.regular)
                            themeManager.setBlurBackground(true)
                        }
                        .font(.custom(customFont, size: 12))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(themeManager.currentTheme.accentColor.opacity(0.2))
                        .foregroundColor(themeManager.currentTheme.textColor)
                        .cornerRadius(6)
                        
                        Button("强烈") {
                            themeManager.setBlurEffect(enabled: true, opacity: 0.95)
                            themeManager.setBlurMaterial(.thick)
                            themeManager.setBlurBackground(true)
                        }
                        .font(.custom(customFont, size: 12))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(themeManager.currentTheme.accentColor.opacity(0.2))
                        .foregroundColor(themeManager.currentTheme.textColor)
                        .cornerRadius(6)
                    }
                }
            }
        }
        .padding()
        .background(themeManager.currentTheme.gridBackgroundColor)
        .cornerRadius(12)
    }
}

struct BlurSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        BlurSettingsView(themeManager: ThemeManager.shared)
            .frame(width: 400, height: 600)
    }
}