import SwiftUI
import AppKit

struct WeatherIcon: View {
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.4, green: 0.6, blue: 0.9),
                    Color(red: 0.2, green: 0.4, blue: 0.8)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // Cloud shape
            CloudShape()
                .fill(Color.white)
                .frame(width: 60, height: 60)
                .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 2)
            
            // Sun rays
            ForEach(0..<8) { index in
                Rectangle()
                    .fill(Color.yellow)
                    .frame(width: 4, height: 20)
                    .offset(y: -30)
                    .rotationEffect(.degrees(Double(index) * 45))
            }
            
            // Sun center
            Circle()
                .fill(Color.yellow)
                .frame(width: 20, height: 20)
        }
    }
}

struct CloudShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        // Main cloud body
        path.move(to: CGPoint(x: rect.width * 0.2, y: rect.height * 0.5))
        path.addCurve(
            to: CGPoint(x: rect.width * 0.8, y: rect.height * 0.5),
            control1: CGPoint(x: rect.width * 0.3, y: rect.height * 0.2),
            control2: CGPoint(x: rect.width * 0.7, y: rect.height * 0.2)
        )
        path.addCurve(
            to: CGPoint(x: rect.width * 0.2, y: rect.height * 0.5),
            control1: CGPoint(x: rect.width * 0.7, y: rect.height * 0.8),
            control2: CGPoint(x: rect.width * 0.3, y: rect.height * 0.8)
        )
        
        return path
    }
}

// Icon sizes required for iOS
let iconSizes = [
    (name: "Icon-20@2x", size: 40),
    (name: "Icon-20@3x", size: 60),
    (name: "Icon-29@2x", size: 58),
    (name: "Icon-29@3x", size: 87),
    (name: "Icon-40@2x", size: 80),
    (name: "Icon-40@3x", size: 120),
    (name: "Icon-60@2x", size: 120),
    (name: "Icon-60@3x", size: 180),
    (name: "Icon-1024", size: 1024) // App Store icon
]

@MainActor
func generateIcons() async {
    let iconView = WeatherIcon()
    let renderer = ImageRenderer(content: iconView)
    
    // Create output directory if it doesn't exist
    let outputDir = "WeatherApp/WeatherApp/Assets.xcassets/AppIcon.appiconset"
    try? FileManager.default.createDirectory(atPath: outputDir, withIntermediateDirectories: true)
    
    // Generate each icon size
    for (name, size) in iconSizes {
        renderer.proposedSize = ProposedViewSize(width: CGFloat(size), height: CGFloat(size))
        if let nsImage = renderer.nsImage {
            if let tiffData = nsImage.tiffRepresentation,
               let bitmapImage = NSBitmapImageRep(data: tiffData),
               let pngData = bitmapImage.representation(using: .png, properties: [:]) {
                let fileURL = URL(fileURLWithPath: "\(outputDir)/\(name).png")
                try? pngData.write(to: fileURL)
                print("Generated \(name).png")
            }
        }
    }
}

// Run the generator
Task { @MainActor in
    await generateIcons()
    exit(0)
}

// Preview
struct WeatherIcon_Previews: PreviewProvider {
    static var previews: some View {
        WeatherIcon()
            .frame(width: 100, height: 100)
            .previewLayout(.sizeThatFits)
    }
} 