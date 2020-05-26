struct UserCredentials: Codable {
    let username: String
    let password: String

    init(email: String = "", password: String = "") {
        self.username = email.lowercased()
        self.password = password
    }
}
