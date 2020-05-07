enum ServerURLs: String {
    case production
    case beta
    case custom
    case reachability

    var description: String {
        switch self {
        case .production:
            return "https://snowflake-qa.herokuapp.com"
        case .beta:
            return "https://snowflake-qa.herokuapp.com"
        case .custom:
            return "https://"
        case .reachability:
        #if BETA
            let newString = ServerURLs.beta.description.replacingOccurrences(of: "https://", with: "", options: .anchored)
        #else
            let newString = ServerURLs.production.description.replacingOccurrences(of: "https://", with: "", options: .anchored)
        #endif

            return newString
        }
    }

    static let allValues = [production, beta, custom]
}

struct Servers {

    var list: [String] = []

    var customType: String {
        return ServerURLs.custom.rawValue
    }

    // MARK: -
    init() {
        for value in ServerURLs.allValues {
            list.append(value.rawValue)
        }

    }

    func valueFromDescription(_ descriptionValue: String) -> String {
        for value in ServerURLs.allValues where value.description == descriptionValue {
            return value.rawValue
        }

        return ServerURLs.custom.rawValue
    }

    func descriptionFromValue(_ value: String) -> String {
        for val in ServerURLs.allValues where valueFromDescription(val.description) == value {
            return val.description
        }

        return ServerURLs.custom.description
    }

    func defaultCustomURLstring() -> String {
        return ServerURLs.custom.description
    }

    func defaultRuntimeURLstring() -> String {
        #if BETA
            return ServerURLs.beta.description
        #else
            return ServerURLs.production.description
        #endif
    }

}
