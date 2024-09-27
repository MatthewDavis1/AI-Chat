import SwiftUI

struct ChatView: View {
    @EnvironmentObject var viewModel: ChatViewModel

    var body: some View {
        VStack {
            ZStack {
                ThemeColors.backgroundDarkNavyBlue.edgesIgnoringSafeArea(.all)
                
                VStack {
                    ScrollViewReader { scrollViewProxy in
                        ScrollView {
                            VStack(alignment: .leading, spacing: 12) {
                                ForEach(Array(viewModel.messages.enumerated()), id: \.element.id) { index, message in
                                    HStack {
                                        if message.isUser {
                                            Spacer()
                                            UserTextMessageView(message: message.message as! TextMessage)
                                        } else {
                                            Group {
                                                switch message.message {
                                                case let pickerMessage as PickerMessage:
                                                    BotPickerMessageView(message: pickerMessage)
                                                case let multiSelectMessage as MultiSelectMessage:
                                                    BotMultiSelectMessageView(message: multiSelectMessage)
                                                case let yesNoMessage as YesNoMessage:
                                                    BotYesNoMessageView(message: yesNoMessage)
                                                case let ratingMessage as RatingMessage:
                                                    BotRatingMessageView(message: ratingMessage)
                                                default:
                                                    BotTextMessageView(message: message.message as! TextMessage)
                                                }
                                            }
                                            Spacer()
                                        }
                                    }
                                }
                            }
                            .padding()
                            .background(GeometryReader { geo -> Color in
                                DispatchQueue.main.async {
                                    let contentHeight = geo.frame(in: .global).height
                                    let scrollViewHeight = geo.size.height
                                    viewModel.isAtBottom = contentHeight <= scrollViewHeight
                                }
                                return Color.clear
                            })
                        }
                        .onChange(of: viewModel.messages.count) { newCount, oldCount in
                            if viewModel.isAtBottom {
                                withAnimation {
                                    scrollViewProxy.scrollTo(viewModel.messages.last?.id, anchor: .bottom)
                                }
                            } else {
                                viewModel.showNewMessageAlert = true
                            }
                        }
                        
                        if viewModel.showNewMessageAlert {
                            Button(action: {
                                withAnimation {
                                    scrollViewProxy.scrollTo(viewModel.messages.last?.id, anchor: .bottom)
                                }
                                viewModel.showNewMessageAlert = false
                            }) {
                                Text("New Message!")
                                    .fontWeight(.bold)
                                    .foregroundColor(ThemeColors.textWhite)
                                    .padding()
                                    .background(ThemeColors.accentDeepBlue)
                                    .cornerRadius(8)
                            }
                            .padding(.bottom, 10)
                        }
                        
                        if viewModel.isLoading {
                            ProgressView()
                                .padding()
                                .background(ThemeColors.cardBackgroundSlightlyLighterNavyBlue)
                                .cornerRadius(8)
                        }
                    }
                    
                    Divider().background(ThemeColors.accentDeepBlue)
                    
                    HStack(spacing: 10) {
                        TextField("Type a message...", text: $viewModel.inputText)
                            .padding(.horizontal, 10)
                            .frame(height: 40)
                            .background(ThemeColors.inputBackgroundDarkGrayishPurple)
                            .foregroundColor(ThemeColors.inputTextWhite)
                            .accentColor(ThemeColors.accentLightPinkishRed)
                            .cornerRadius(20) // Roundedness of text input window
                            .textFieldStyle(PlainTextFieldStyle()) // Ensures the cursor is positioned correctly
                            .onSubmit {
                                viewModel.sendMessage()
                            }
                        
                        Button(action: viewModel.sendMessage) {
                            Text("Send")
                                .fontWeight(.semibold)
                                .foregroundColor(ThemeColors.textWhite)
                                .frame(height: 40)
                                .padding(.horizontal, 16)
                                .background(viewModel.inputText.isEmpty ? ThemeColors.disabledTextDarkGray : ThemeColors.accentDeepBlue)
                                .cornerRadius(20)
                        }
                        .disabled(viewModel.inputText.isEmpty || viewModel.isLoading)
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 10)
                }
            }
            .contextMenu {
                Button(action: viewModel.clearMessages) {
                    Text("Clear Chat")
                    Image(systemName: "trash")
                }
            }
        }
    }
}

extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content) -> some View {

        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}

struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        ChatView()
            .environmentObject(ChatViewModel())
            .environment(\.colorScheme, .dark)
            .previewLayout(.sizeThatFits)
    }
}
