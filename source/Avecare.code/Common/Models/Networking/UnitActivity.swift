import Foundation

struct CreateUnitActivityRequest: Codable {
    let activityId: Int
    let date: Date
    let instructions: String
}

struct UnitActivity: Codable, CustomStringConvertible, SingleValuePickerItem {
    let id: Int
    let description: String
    let isActive: Bool
}

typealias UnitActivityResponse = APIResponse<[UnitActivity]>
