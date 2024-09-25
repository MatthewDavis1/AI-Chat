import SwiftUI


struct CustomSlider: View {
    @Binding var value: Double
    var range: ClosedRange<Double>
    var step: Double
    var trackHeight: CGFloat // Parameter for track height

    var body: some View {
        VStack {
            GeometryReader { geometry in
                let width = geometry.size.width
                let height = trackHeight // Use the track height parameter

                // Background track (unfilled)
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: height)
                    .cornerRadius(height / 2)

                // Filled track (left side) - Changed to pinkish red
                Rectangle()
                    .fill(ThemeColors.accentLightPinkishRed) // Updated color
                    .frame(width: CGFloat((value - range.lowerBound) / (range.upperBound - range.lowerBound)) * (width), height: height) // Adjusted width calculation
                    .cornerRadius(height / 2)

                // Slider thumb
                Circle()
                    .fill(Color.white) // Thumb color
                    .frame(width: height, height: height)
                    .offset(x: min(max(CGFloat((value - range.lowerBound) / (range.upperBound - range.lowerBound)) * (width) - (height / 2), 0), width - height)) // Bounded offset calculation
                    .gesture(DragGesture()
                        .onChanged { gesture in
                            let newValue = min(max(range.lowerBound, Double(gesture.location.x / (width) * (range.upperBound - range.lowerBound) + range.lowerBound)), range.upperBound)
                            value = round(newValue / step) * step // Snap to step
                        }
                    )
            }
            .frame(height: trackHeight) // Set the height of the geometry reader
        }
    }
}

