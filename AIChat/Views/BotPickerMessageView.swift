import SwiftUI

struct BotPickerMessageView: View {
    var message: PickerMessage
    @State private var selectedOption: String?
    @State private var isAnswered = false
    @State private var isSkipped = false
    @EnvironmentObject var viewModel: ChatViewModel
    
    init(message: PickerMessage) {
        self.message = message
        _selectedOption = State(initialValue: message.options.first)
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
                    Picker("Select an option", selection: $selectedOption) {
                        ForEach(message.options, id: \.self) { option in
                            Text(option).tag(option as String?)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .accentColor(ThemeColors.accentLightPinkishRed)
                    
                    HStack {
                        Button("Confirm") {
                            isAnswered = true
                            sendResponse()
                        }
                        .disabled(selectedOption == nil)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                        .background(selectedOption == nil ? ThemeColors.disabledTextDarkGray : ThemeColors.accentLightPinkishRed)
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
                    Text("Selected: \(selectedOption ?? "")")
                        .foregroundColor(ThemeColors.accentLightPinkishRed)
                }
            }
        }
    }
    
    private func sendResponse() {
        guard let selectedOption = selectedOption else { return }
        let responseText = "User selected option for: \(message.text)\nSelected option: \(selectedOption)"
        viewModel.sendResponseMessage(TextMessage(text: responseText))
    }
    
    private func sendSkipResponse() {
        let skipText = "User skipped the picker question: \(message.text)"
        viewModel.sendResponseMessage(TextMessage(text: skipText))
    }
}
