struct MultiSelectMessage: Message {
    var id: Int
    var text: String
    var isUser: Bool
    var options: [String]
}
