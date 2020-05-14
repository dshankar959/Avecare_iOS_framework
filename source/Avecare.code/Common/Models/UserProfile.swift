struct UserProfile: Codable {
    private let userCredentials: UserCredentials

    var isLastSignedIn: Bool = false

    var accountType: String? {
        let accountInfo = RLMAccountInfo.findAll().first
        return accountInfo?.accountType
    }

    var accountTypeId: String? {
        let accountInfo = RLMAccountInfo.findAll().first
        return accountInfo?.id
    }

    var isSupervisor: Bool {
        if let type = accountType, type.caseInsensitiveCompare("supervisor") == .orderedSame {
            return true
        }

        return false
    }


    // MARK: -

    enum CodingKeys: String, CodingKey {
        case userCredentials
    }
/*
    init(from decoder: Decoder) throws {
        self.init()
        try self.decode(from: decoder)
    }

    func decode(from decoder: Decoder) throws {
        do {
            let values = try decoder.container(keyedBy: CodingKeys.self)

            self.email = try values.decode(String.self, forKey: .email)
            self.password = try values.decode(String.self, forKey: .password)

        } catch {
            DDLogError("JSON Decoding error = \(error)")
            fatalError("JSON Decoding error = \(error)")
        }
    }
*/

    init(userCredentials: UserCredentials = UserCredentials()) {
        self.userCredentials = userCredentials
    }

    var email: String {
        return userCredentials.username
    }

    var password: String {
        return userCredentials.password
    }

    func isEmpty() -> Bool {
        return email.isEmpty
    }



}
