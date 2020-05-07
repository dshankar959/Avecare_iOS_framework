import Foundation

struct InstitutionDetails: Codable {
    let id: Int
    let organizationId: Int
    let name: String
}

typealias InstitutionDetailsResponse = InstitutionDetails

/*
"id": 10,
"createdAt": "2020-04-29T15:07:59.925574",
"updatedAt": "2020-04-29T15:07:59.925574",
"isActive": true,
"name": "St. Stephens",
"mealPlan": null,
"activities": null,
"organizationId": 1
*/



