import Foundation

struct UnitDetails: Codable {
    let id: Int
    let institutionId: Int
    let name: String
}

typealias UnitDetailsResponse = APIResponse<UnitDetails>
