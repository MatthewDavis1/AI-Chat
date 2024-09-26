protocol Message: Identifiable, Codable {
    var id: Int { get }
    var text: String { get }
    var isUser: Bool { get }
}

