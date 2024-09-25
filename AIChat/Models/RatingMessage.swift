struct RatingMessage: Message {
    var id: Int
    var text: String
    var isUser: Bool
    var range: ClosedRange<Double>
    var step: Double
    var scaleType: ScaleType // New property to differentiate between types
    var isInteger: Bool // New property to indicate if the rating should be an integer

    enum ScaleType {
        case oneToTen
        case zeroToHundred
    }
}
