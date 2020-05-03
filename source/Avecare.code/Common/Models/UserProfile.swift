struct UserProfile: Codable {
    private let userCredentials: UserCredentials

    var isLastSignedIn: Bool = false

    var details: SupervisorDetails?

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
