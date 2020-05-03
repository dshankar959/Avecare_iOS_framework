import Foundation

struct APIResponse<T: Decodable>: Decodable {
    let results: T
}
