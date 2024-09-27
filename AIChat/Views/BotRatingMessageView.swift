import SwiftUI

struct BotRatingMessageView: View {
    var message: RatingMessage
    @State private var selectedValue: Double
    @State private var isAnswered = false
    @State private var isSkipped = false
    @EnvironmentObject var viewModel: ChatViewModel

    init(message: RatingMessage) {
        self.message = message
        _selectedValue = State(initialValue: Double(message.rangeLow))
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
                    CustomSlider(value: $selectedValue, 
                                 range: Double(message.rangeLow)...Double(message.rangeHigh), 
                                 step: 1, 
                                 trackHeight: 30)
                    Text("Selected value: \(Int(selectedValue))")
                        .foregroundColor(ThemeColors.accentLightPinkishRed)

                    HStack {
                        Button("Confirm") {
                            isAnswered = true
                            sendResponse()
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                        .background(ThemeColors.accentLightPinkishRed)
                        .foregroundColor(ThemeColors.textWhite)
                        .cornerRadius(8)

                        Button("Skip") {
                            isSkipped = true
                            sendSkipResponse()
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
                    Text("Answer: \(Int(selectedValue))")
                        .foregroundColor(ThemeColors.accentLightPinkishRed)
                }
            }
        }
    }

    private func sendResponse() {
        let responseText = "User rated for: \(message.text)\nRating: \(Int(selectedValue))"
        viewModel.sendResponseMessage(TextMessage(text: responseText))
    }

    private func sendSkipResponse() {
        let skipText = "User skipped the rating question: \(message.text)"
        viewModel.sendResponseMessage(TextMessage(text: skipText))
    }
}
