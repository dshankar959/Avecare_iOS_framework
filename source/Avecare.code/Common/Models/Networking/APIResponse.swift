import Foundation



struct APIResponse<T: Decodable>: Decodable {
    let results: T
}


struct APIListResponse<T: Decodable>: Decodable {

    let count: Int
    let next: String?
    let previous: String?
    let results: [T]

    private enum JSONCodingKeys: String, CodingKey {
        case count
        case next
        case previous
        case results
    }

    init() {
        self.count = 0
        self.next = nil
        self.previous = nil
        self.results = []
    }

}
