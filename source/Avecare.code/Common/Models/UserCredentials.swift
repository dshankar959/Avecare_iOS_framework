struct UserCredentials: Codable {
    let username: String
    let password: String

    init(email: String = "", password: String = "") {
//        self.username = email.lowercased()
        self.username = email   // FIXME:  temporary until server-side updates support
        self.password = password
    }
}
