import SwiftUI

struct BotRatingMessageView: View {
    var message: RatingMessage
    @State private var selectedValue: Double
    @State private var isAnswered = false
    @State private var isSkipped = false

    init(message: RatingMessage) {
        self.message = message
        _selectedValue = State(initialValue: message.range.lowerBound)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if !isSkipped {
                Text(message.text)
                    .padding(10)
                    .background(ThemeColors.cardBackgroundSlightlyLighterNavyBlue)
                    .foregroundColor(ThemeColors.textWhite)
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(ThemeColors.accentLightPinkishRed, lineWidth: 2)
                    )
                    .shadow(color: ThemeColors.blackBlack.opacity(0.1), radius: 5, x: 0, y: 2)

                if !isAnswered {
                    CustomSlider(value: $selectedValue, range: message.range, step: message.step, trackHeight: 30) // Set the track height to 30 for a taller appearance
                    Text("Selected value: \(message.isInteger ? String(Int(selectedValue)) : String(format: "%.2f", selectedValue))")
                        .foregroundColor(ThemeColors.accentLightPinkishRed)

                    HStack {
                        Button("Confirm") {
                            isAnswered = true
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                        .background(ThemeColors.accentLightPinkishRed)
                        .foregroundColor(ThemeColors.textWhite)
                        .cornerRadius(8)

                        Button("Skip") {
                            isSkipped = true
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                        .background(ThemeColors.cardBackgroundSlightlyLighterNavyBlue)
                        .foregroundColor(ThemeColors.secondaryTextLightGray)
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(ThemeColors.secondaryTextLightGray, lineWidth: 1)
                        )
                    }
                } else {
                    Text("Answer: \(message.isInteger ? String(Int(selectedValue)) : String(format: "%.2f", selectedValue))")
                        .foregroundColor(ThemeColors.accentLightPinkishRed)
                }
            }
        }
    }
}
