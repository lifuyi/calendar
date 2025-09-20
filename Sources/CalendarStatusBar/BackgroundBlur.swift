import SwiftUI

#if canImport(AppKit)
import AppKit

struct BackgroundBlur: NSViewRepresentable {
    var material: NSVisualEffectView.Material
    var blendingMode: NSVisualEffectView.BlendingMode
    var opacity: Double
    
    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = material
        view.blendingMode = .behindWindow  // This makes it blur what's behind
        view.alphaValue = CGFloat(opacity)
        view.state = .active
        
        // Enable layer and set corner radius
        view.wantsLayer = true
        view.layer?.cornerRadius = 10
        
        return view
    }
    
    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        nsView.material = material
        nsView.blendingMode = .behindWindow  // Always blur what's behind
        nsView.alphaValue = CGFloat(opacity)
    }
}

#elseif canImport(UIKit)
import UIKit

struct BackgroundBlur: UIViewRepresentable {
    var style: UIBlurEffect.Style
    var opacity: Double
    
    func makeUIView(context: Context) -> UIVisualEffectView {
        let view = UIVisualEffectView(effect: UIBlurEffect(style: style))
        view.alpha = CGFloat(opacity)
        
        return view
    }
    
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        uiView.effect = UIBlurEffect(style: style)
        uiView.alpha = CGFloat(opacity)
    }
}
#endif

// A view modifier that applies background blur
struct BackgroundBlurModifier: ViewModifier {
    let material: NSVisualEffectView.Material
    let opacity: Double
    let enabled: Bool
    
    func body(content: Content) -> some View {
        if enabled {
            content
                .background(
                    BackgroundBlur(
                        material: material,
                        blendingMode: .behindWindow,
                        opacity: opacity
                    )
                )
        } else {
            content
        }
    }
}

// Extension to make it easy to use
extension View {
    func backgroundBlur(
        material: NSVisualEffectView.Material = .menu,
        opacity: Double = 0.8,
        enabled: Bool = true
    ) -> some View {
        self.modifier(BackgroundBlurModifier(
            material: material,
            opacity: opacity,
            enabled: enabled
        ))
    }
}