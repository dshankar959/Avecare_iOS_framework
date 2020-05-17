import Foundation
import Moya
import CocoaLumberjack

protocol MultipartEncodable {
    var formData: [Moya.MultipartFormData] { get }
}

struct FileAPIModel: Codable {
    let id: String
    let fileName: String
    let fileUrl: String
}

struct DailyFormAPIModel {

    let id: String
    let subjectId: String
    let date: Date
    let log: RLMLogForm
    let storage: ImageStorageService

    private enum CodingKeys: String, CodingKey {
        case id, subjectId, date, log, files
    }

    init(form: RLMLogForm, subjectId: String, storage: ImageStorageService) {
        self.id = newUUID
        self.subjectId = subjectId
        self.date = Date()
        self.log = form
        self.storage = storage
    }

}

extension DailyFormAPIModel: MultipartEncodable {
    var formData: [Moya.MultipartFormData] {
        var data = [Moya.MultipartFormData]()
        if let value = id.data(using: .utf8) {
            data.append(.init(provider: .data(value), name: CodingKeys.id.rawValue))
        }

        do {
            let formJson = try JSONEncoder().encode(log)
            data.append(.init(provider: .data(formJson), name: CodingKeys.log.rawValue))
        } catch {
            DDLogError("JSON Encoding error = \(error)")
            fatalError("JSON Encoding error = \(error)")
        }
        if let value = Date.yearMonthDayFormatter.string(from: Date()).data(using: .utf8) {
            data.append(.init(provider: .data(value), name: CodingKeys.date.rawValue))
        }

        log.rows.compactMap({ $0.photo }).forEach({
            if let url = storage.imageURL(name: $0.filename) {
                // FIXME: filename uploads/f7f80844-3f74-4ab7-95ac-36fee470f859.jpg
                data.append(.init(provider: .file(url), name: $0.filename, fileName: $0.filename))
            }
        })

        return data
    }
}

struct FilesAPIResponseModel: Decodable {
    let files: [FileAPIModel]
}
