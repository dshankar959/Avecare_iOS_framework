import Foundation
import Moya
import CocoaLumberjack


protocol MultipartEncodable {
    var formData: [Moya.MultipartFormData] { get }
}


struct DailyFormAPIModel {

    let id: String
    let subjectId: String
    let date: Date
    let log: RLMLogForm
    let files: [FilesResponseModel.File]
    private enum CodingKeys: String, CodingKey {
        case id, subjectId, date, log, files
    }

    init(form: RLMLogForm, storage: ImageStorageService) {
        self.id = newUUID
        guard let subjectId = form.subject?.id else {
            fatalError()
        }
        self.subjectId = subjectId
        self.date = Date()
        self.log = form

        // files array used only when receive response from server
        self.files = .init()
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

        let storage = ImageStorageService()
        log.rows.compactMap({ $0.photo }).forEach({
            if let url = storage.imageURL(name: $0.id) {
                data.append(.init(provider: .file(url), name: $0.id))
            }
        })

        return data
    }
}

extension DailyFormAPIModel: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(String.self, forKey: .id)
        subjectId = try container.decode(String.self, forKey: .subjectId)
        let formatter = Date.yearMonthDayFormatter
        guard let date = formatter.date(from: try container.decode(String.self, forKey: .date)) else {
            DDLogError("JSON DECODING ERROR: Invalid date format")
            fatalError("JSON DECODING ERROR: Invalid date format")
        }
        self.date = date
        log = try container.decode(RLMLogForm.self, forKey: .log)
        files = try container.decode([FilesResponseModel.File].self, forKey: .files)
    }
}