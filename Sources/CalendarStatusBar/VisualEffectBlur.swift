import SwiftUI

#if canImport(AppKit)
import AppKit

struct VisualEffectBlur: NSViewRepresentable {
    var material: NSVisualEffectView.Material
    var blendingMode: NSVisualEffectView.BlendingMode
    var opacity: Double
    var blurBackground: Bool = false  // New parameter to control blur direction
    
    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = material
        // If blurBackground is true, always use .behindWindow to blur what's behind
        view.blendingMode = blurBackground ? .behindWindow : blendingMode
        view.alphaValue = CGFloat(opacity)
        view.state = .active
        
        // Enhanced blur effect with better visual properties
        view.wantsLayer = true
        view.layer?.cornerRadius = 10
        
        // Improve blur quality and performance
        if blurBackground {
            view.layer?.masksToBounds = false
            view.layer?.shouldRasterize = false
            // For background blur, we want smooth edges
            view.layer?.allowsEdgeAntialiasing = true
        } else {
            // For foreground blur, optimize for clarity
            view.layer?.masksToBounds = true
            view.layer?.shouldRasterize = true
            view.layer?.rasterizationScale = NSScreen.main?.backingScaleFactor ?? 2.0
        }
        
        return view
    }
    
    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        nsView.material = material
        // If blurBackground is true, always use .behindWindow to blur what's behind
        nsView.blendingMode = blurBackground ? .behindWindow : blendingMode
        nsView.alphaValue = CGFloat(opacity)
    }
}

#elseif canImport(UIKit)
import UIKit

struct VisualEffectBlur: UIViewRepresentable {
    var style: UIBlurEffect.Style
    var opacity: Double
    
    func makeUIView(context: Context) -> UIVisualEffectView {
        let view = UIVisualEffectView(effect: UIBlurEffect(style: style))
        view.alpha = CGFloat(opacity)
        
        // Add vibrancy effect for more pronounced blur
        let vibrancyEffect = UIVibrancyEffect(blurEffect: UIBlurEffect(style: style))
        let vibrancyView = UIVisualEffectView(effect: vibrancyEffect)
        vibrancyView.frame = view.bounds
        vibrancyView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.contentView.addSubview(vibrancyView)
        
        return view
    }
    
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        uiView.effect = UIBlurEffect(style: style)
        uiView.alpha = CGFloat(opacity)
    }
}
#endif