enum ServerURLs: String, CaseIterable {
    case production
    case beta
    case qa
    case custom
    case reachability

    var description: String {
        switch self {
        case .production:
            return "https://avecare.ca"
        case .beta:
            return "https://avecare-beta.herokuapp.com"
        case .qa:
            return "https://snowflake-qa.herokuapp.com"
        case .custom:
            return "https://"
        case .reachability:
        #if QA
            let newString = ServerURLs.qa.description.replacingOccurrences(of: "https://", with: "", options: .anchored)
        #elseif BETA
            let newString = ServerURLs.beta.description.replacingOccurrences(of: "https://", with: "", options: .anchored)
        #else
            let newString = ServerURLs.production.description.replacingOccurrences(of: "https://", with: "", options: .anchored)
        #endif

            return newString
        }
    }
}


struct Servers {

    var list: [String] = []

    var customType: String {
        return ServerURLs.custom.rawValue
    }

    // MARK: -
    init() {
        for value in ServerURLs.allCases {
            list.append(value.rawValue)
        }
    }

    func valueFromDescription(_ descriptionValue: String) -> String {
        for value in ServerURLs.allCases where value.description == descriptionValue {
            return value.rawValue
        }

        return ServerURLs.custom.rawValue
    }

    func descriptionFromValue(_ value: String) -> String {
        for val in ServerURLs.allCases where valueFromDescription(val.description) == value {
            return val.description
        }

        return ServerURLs.custom.description
    }

    func defaultCustomURLstring() -> String {
        return ServerURLs.custom.description
    }

    func defaultRuntimeURLstring() -> String {
        #if QA
            return ServerURLs.qa.description
        #elseif BETA
            return ServerURLs.beta.description
        #else
            return ServerURLs.production.description
        #endif
    }

}
