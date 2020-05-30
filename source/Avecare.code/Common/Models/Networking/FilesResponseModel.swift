import Foundation



struct FilesResponseModel: Decodable {

    struct File: Codable {
        let id: String
        let fileName: String
        let fileUrl: String
    }

    let files: [File]
}
