import SwiftUI

struct BlurDemoView: View {
    @ObservedObject var themeManager: ThemeManager
    @State private var showingDemo = false
    private let customFont = "dingliesongtypeface"
    
    var body: some View {
        VStack(spacing: 20) {
            Text("毛玻璃效果演示")
                .font(.custom(customFont, size: 24))
                .fontWeight(.bold)
                .foregroundColor(themeManager.currentTheme.textColor)
            
            Text("通过右键菜单可以访问所有虚化设置")
                .font(.custom(customFont, size: 14))
                .foregroundColor(themeManager.currentTheme.secondaryTextColor)
            
            // Demo content areas
            HStack(spacing: 16) {
                // Background blur demo
                VStack {
                    Text("背景虚化")
                        .font(.custom(customFont, size: 16))
                        .fontWeight(.medium)
                        .foregroundColor(themeManager.currentTheme.textColor)
                    
                    ZStack {
                        // Background content
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.blue.opacity(0.8),
                                Color.purple.opacity(0.6),
                                Color.pink.opacity(0.4)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        
                        VStack {
                            Text("内容保持清晰")
                                .font(.custom(customFont, size: 14))
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                            
                            Text("背景被虚化")
                                .font(.custom(customFont, size: 12))
                                .foregroundColor(.white.opacity(0.8))
                        }
                        .padding()
                    }
                    .frame(width: 150, height: 100)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                    )
                    .optimizedBackgroundBlur(
                        material: themeManager.currentTheme.blurMaterial.nsMaterial,
                        opacity: themeManager.currentTheme.blurBackground ? themeManager.currentTheme.blurOpacity : 0,
                        intensity: .moderate
                    )
                }
                
                // Foreground blur demo
                VStack {
                    Text("前景虚化")
                        .font(.custom(customFont, size: 16))
                        .fontWeight(.medium)
                        .foregroundColor(themeManager.currentTheme.textColor)
                    
                    ZStack {
                        // Background content
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.green.opacity(0.8),
                                Color.blue.opacity(0.6),
                                Color.cyan.opacity(0.4)
                            ]),
                            startPoint: .topTrailing,
                            endPoint: .bottomLeading
                        )
                        
                        VStack {
                            Text("内容也被虚化")
                                .font(.custom(customFont, size: 14))
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                            
                            Text("传统毛玻璃效果")
                                .font(.custom(customFont, size: 12))
                                .foregroundColor(.white.opacity(0.8))
                        }
                        .padding()
                    }
                    .frame(width: 150, height: 100)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                    )
                    .optimizedForegroundBlur(
                        material: themeManager.currentTheme.blurMaterial.nsMaterial,
                        opacity: !themeManager.currentTheme.blurBackground ? themeManager.currentTheme.blurOpacity : 0,
                        intensity: .moderate
                    )
                }
            }
            
            // Current settings display
            VStack(alignment: .leading, spacing: 8) {
                Text("当前设置")
                    .font(.custom(customFont, size: 18))
                    .fontWeight(.semibold)
                    .foregroundColor(themeManager.currentTheme.textColor)
                
                HStack {
                    Text("状态:")
                        .font(.custom(customFont, size: 14))
                        .foregroundColor(themeManager.currentTheme.secondaryTextColor)
                    Text(themeManager.currentTheme.blurEnabled ? "已启用" : "已禁用")
                        .font(.custom(customFont, size: 14))
                        .fontWeight(.medium)
                        .foregroundColor(themeManager.currentTheme.blurEnabled ? .green : .red)
                }
                
                if themeManager.currentTheme.blurEnabled {
                    HStack {
                        Text("方向:")
                            .font(.custom(customFont, size: 14))
                            .foregroundColor(themeManager.currentTheme.secondaryTextColor)
                        Text(themeManager.currentTheme.blurBackground ? "背景虚化" : "前景虚化")
                            .font(.custom(customFont, size: 14))
                            .fontWeight(.medium)
                            .foregroundColor(themeManager.currentTheme.accentColor)
                    }
                    
                    HStack {
                        Text("材质:")
                            .font(.custom(customFont, size: 14))
                            .foregroundColor(themeManager.currentTheme.secondaryTextColor)
                        Text(themeManager.currentTheme.blurMaterial.displayName)
                            .font(.custom(customFont, size: 14))
                            .fontWeight(.medium)
                            .foregroundColor(themeManager.currentTheme.textColor)
                    }
                    
                    HStack {
                        Text("强度:")
                            .font(.custom(customFont, size: 14))
                            .foregroundColor(themeManager.currentTheme.secondaryTextColor)
                        Text("\(Int(themeManager.currentTheme.blurOpacity * 100))%")
                            .font(.custom(customFont, size: 14))
                            .fontWeight(.medium)
                            .foregroundColor(themeManager.currentTheme.textColor)
                    }
                }
            }
            .padding()
            .background(
                themeManager.currentTheme.blurEnabled ?
                AnyView(
                    OptimizedBlurEffect(
                        material: .menu,
                        opacity: 0.3,
                        blurBackground: true,
                        intensity: .subtle
                    )
                ) :
                AnyView(themeManager.currentTheme.gridBackgroundColor.opacity(0.5))
            )
            .cornerRadius(12)
            
            Text("💡 右键点击状态栏图标 → 毛玻璃效果 → 进行设置")
                .font(.custom(customFont, size: 12))
                .foregroundColor(themeManager.currentTheme.secondaryTextColor)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}

struct BlurDemoView_Previews: PreviewProvider {
    static var previews: some View {
        BlurDemoView(themeManager: ThemeManager.shared)
            .frame(width: 400, height: 500)
            .background(Color.black.opacity(0.1))
    }
}