import Foundation



struct CreateUnitActivityRequest: Codable {
    let activityId: String
    let date: Date
    let instructions: String
}
