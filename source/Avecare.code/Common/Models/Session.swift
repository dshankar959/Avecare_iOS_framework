struct Session {
    var token = APIToken()
    var userProfile = UserProfile()

    func isSignedIn() -> Bool {
        return token.isValid()
    }

}
