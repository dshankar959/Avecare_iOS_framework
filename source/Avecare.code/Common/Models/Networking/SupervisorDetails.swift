import Foundation

struct SupervisorDetails: Codable {
    let id: Int
    let title: String
    let firstName: String
    let middleName: String
    let lastName: String
//    let isUnitType: Bool
    let primaryUnitId: Int
//    let showInUnitList: Bool
    let bio: String
    // TODO:  "educationalBackground":
}

typealias SupervisorDetailsResponse = APIResponse<SupervisorDetails>
