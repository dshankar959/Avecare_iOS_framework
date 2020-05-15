import CocoaLumberjack



struct APIToken: Decodable {

    let accountType: String
    let accountTypeId: String
    let accessToken: String

    var isFake: Bool = false


    private var issueDateTime: Date = {
        DDLogDebug("issueDateTime = \(Date.ISO8601StringFromDate(Date()))")
        return Date()
    }()

    private enum CodingKeys: String, CodingKey {
        case accountType
        case accountTypeId
        case accessToken = "token"
    }

    init(withToken: String = "", accountType: String = "", accountTypeId: String = "", isFakeToken: Bool = false) {
        self.accountType = accountType
        self.accountTypeId = accountTypeId
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
