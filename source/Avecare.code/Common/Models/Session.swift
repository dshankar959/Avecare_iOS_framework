struct Session {
    var token = APIToken()
    var userProfile = UserProfile()

    var unitDetails: UnitDetails?
    var institutionDetails: InstitutionDetails?

    func isSignedIn() -> Bool {
        return token.isValid()
    }

}
