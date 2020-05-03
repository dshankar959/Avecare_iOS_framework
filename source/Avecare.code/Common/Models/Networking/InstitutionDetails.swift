import Foundation

struct InstitutionDetails: Codable {
    let id: Int
    let organizationId: Int
    let name: String
}

typealias InstitutionDetailsResponse = APIResponse<InstitutionDetails>
