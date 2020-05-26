struct UserProfile: Codable {
    private let userCredentials: UserCredentials

    var isLastSignedIn: Bool = false


    enum CodingKeys: String, CodingKey {
        case userCredentials
    }

    // MARK: -

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


extension UserProfile {

    private var accountType: String? {
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

    var isGuardian: Bool {
        return !isSupervisor
    }

}
