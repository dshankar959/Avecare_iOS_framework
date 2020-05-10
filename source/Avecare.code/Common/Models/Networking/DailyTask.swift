import Foundation


struct DailyTask: Codable {
    struct Complete: Codable {
        let id: Int
        let completed: Bool
    }

    let id: Int
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