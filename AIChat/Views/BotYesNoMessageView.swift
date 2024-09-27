import SwiftUI

struct BotYesNoMessageView: View {
    var message: YesNoMessage
    @State private var response: Bool?
    @State private var isAnswered = false
    @State private var isSkipped = false
    @EnvironmentObject var viewModel: ChatViewModel
    
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
                    HStack {
                        Button(action: { response = true }) {
                            Text("Yes")
                                .foregroundColor(response == true ? ThemeColors.textWhite : ThemeColors.accentLightPinkishRed)
                                .padding(.vertical, 8)
                                .padding(.horizontal, 16)
                                .background(response == true ? ThemeColors.accentLightPinkishRed : ThemeColors.cardBackgroundSlightlyLighterNavyBlue)
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(ThemeColors.accentLightPinkishRed, lineWidth: 1)
                                )
                        }
                        
                        Button(action: { response = false }) {
                            Text("No")
                                .foregroundColor(response == false ? ThemeColors.textWhite : ThemeColors.accentLightPinkishRed)
                                .padding(.vertical, 8)
                                .padding(.horizontal, 16)
                                .background(response == false ? ThemeColors.accentLightPinkishRed : ThemeColors.cardBackgroundSlightlyLighterNavyBlue)
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(ThemeColors.accentLightPinkishRed, lineWidth: 1)
                                )
                        }
                    }
                    
                    HStack {
                        Button("Confirm") {
                            isAnswered = true
                            sendResponse()
                        }
                        .disabled(response == nil)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                        .background(response == nil ? ThemeColors.disabledTextDarkGray : ThemeColors.accentLightPinkishRed)
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
                    Text("Answer: \(response == true ? "Yes" : "No")")
                        .foregroundColor(ThemeColors.accentLightPinkishRed)
                }
            }
        }
    }
    
    private func sendResponse() {
        guard let response = response else { return }
        let responseText = "User responded \(response ? "Yes" : "No") to: \(message.text)"
        viewModel.sendCustomMessage(TextMessage(text: responseText))
    }
    
    private func sendSkipResponse() {
        let skipText = "User skipped the question: \(message.text)"
        viewModel.sendCustomMessage(TextMessage(text: skipText))
    }
}

