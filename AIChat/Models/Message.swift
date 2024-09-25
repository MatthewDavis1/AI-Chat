protocol Message: Identifiable {
    var id: Int { get }
    var text: String { get }
    var isUser: Bool { get }
}

