import Foundation

struct OrganizationDetails: Codable {
    let id: Int
    let name: String
}

typealias OrganizationDetailsResponse = APIResponse<OrganizationDetails>
