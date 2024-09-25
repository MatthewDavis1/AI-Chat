import SwiftUI

struct BotPickerMessageView: View {
    var message: PickerMessage
    @State private var selectedOption: String?
    @State private var isAnswered = false
    @State private var isSkipped = false
    
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
                        }
                        .disabled(selectedOption == nil)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                        .background(selectedOption == nil ? ThemeColors.disabledTextDarkGray : ThemeColors.accentLightPinkishRed)
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
                    Text("Selected: \(selectedOption ?? "")")
                        .foregroundColor(ThemeColors.accentLightPinkishRed)
                }
            }
        }
    }
}
