import SwiftUI

struct BotMultiSelectMessageView: View {
    var message: MultiSelectMessage
    @State private var selectedOptions: Set<String> = []
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
                    ForEach(message.options, id: \.self) { option in
                        HStack {
                            Text(option)
                                .foregroundColor(ThemeColors.textWhite)
                            Spacer()
                            Image(systemName: selectedOptions.contains(option) ? "checkmark.square.fill" : "square")
                                .foregroundColor(ThemeColors.accentLightPinkishRed)
                                .font(.system(size: 24))
                                .onTapGesture {
                                    if selectedOptions.contains(option) {
                                        selectedOptions.remove(option)
                                    } else {
                                        selectedOptions.insert(option)
                                    }
                                }
                        }
                        .padding(.vertical, 4)
                    }
                    
                    HStack {
                        Button("Confirm") {
                            isAnswered = true
                            sendResponse()
                        }
                        .disabled(selectedOptions.isEmpty)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                        .background(selectedOptions.isEmpty ? ThemeColors.disabledTextDarkGray : ThemeColors.accentLightPinkishRed)
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
                    Text("Selected: \(selectedOptions.joined(separator: ", "))")
                        .foregroundColor(ThemeColors.accentLightPinkishRed)
                }
            }
        }
    }
    
    private func sendResponse() {
        let responseText = "User selected options for: \(message.text)\nSelected options: \(selectedOptions.joined(separator: ", "))"
        viewModel.sendCustomMessage(TextMessage(text: responseText))
    }
    
    private func sendSkipResponse() {
        let skipText = "User skipped the multi-select question: \(message.text)"
        viewModel.sendCustomMessage(TextMessage(text: skipText))
    }
}

