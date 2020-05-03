import CocoaLumberjack

struct APIToken: Decodable {
    let accessToken: String

    var isFake: Bool = false

    private var issueDateTime: Date = {
        DDLogDebug("issueDateTime = \(Date.ISO8601StringFromDate(Date()))")
        return Date()
    }()

    /// Overriding the property names, with custom property names when the json field is different,
    /// requires defining a `CodingKeys` enum and providing a case for each property.
    /// The case itself should match the property, and its rawValue of type string, should correspond
    /// to the JSON field name.
    private enum CodingKeys: String, CodingKey {
        case accessToken = "token"
    }

    init(withToken: String = "", isFakeToken: Bool = false) {
        self.accessToken = withToken
        self.isFake = isFakeToken
    }

    func isValid() -> Bool {
        if isFake || accessToken.isEmpty {
            DDLogDebug("isFake = \(isFake ? "YES" : "NO")")
            DDLogDebug("accessToken.isEmpty = \(accessToken.isEmpty ? "YES" : "NO")")
            return false
        }

        // Check if expired perhaps.
        // In this arbitrary case, we just check if it's still `today`.
        let calendar = Calendar.current
        if !calendar.isDateInToday(issueDateTime) {
            DDLogDebug("issueDateTime = expired")
            return false
        }

        return true
    }

}
