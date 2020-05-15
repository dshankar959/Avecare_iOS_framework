import Foundation



struct CreateUnitActivityRequest: Codable {
    let activityId: String
    let date: Date
    let instructions: String
}


struct UnitActivity: Codable, CustomStringConvertible, SingleValuePickerItem {
    let id: String
    let description: String
    let isActive: Bool
}


typealias UnitActivityResponse = APIResponse<[UnitActivity]>
