import Foundation



struct DailyTask: Codable {
    struct Complete: Codable {
        let id: String
        let completed: Bool
    }

    let id: String
    let description: String


/*
  "id": 1,
  "description": "Flush toilets",
  "isActive": true,
  "order": 1
*/


}


struct DailyTaskRequest: Codable {
    let date: Date
    let tasks: [DailyTask.Complete]
}


struct DailyTaskResponse: Codable {
    let id: Int
    let date: Date
    let tasks: [DailyTask.Complete]
}
