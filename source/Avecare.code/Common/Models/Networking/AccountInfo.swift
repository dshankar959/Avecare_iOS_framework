import Foundation

struct AccountInfo: Codable {
    let accountType: String
    let accountTypeId: Int
}

typealias AccountInfoResponse = APIResponse<AccountInfo>
