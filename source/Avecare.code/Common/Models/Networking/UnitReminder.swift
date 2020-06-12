import Foundation


struct UnitReminder: Codable, CustomStringConvertible, SingleValuePickerItem {
    let id: String
    let description: String
    let isActive: Bool
}

typealias UnitReminderResponse = APIResponse<[UnitReminder]>
