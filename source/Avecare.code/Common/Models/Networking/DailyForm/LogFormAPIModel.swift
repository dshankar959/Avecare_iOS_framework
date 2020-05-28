import Foundation
import Moya
import CocoaLumberjack


protocol MultipartEncodable {
    var formData: [Moya.MultipartFormData] { get }
}


struct LogFormAPIModel {

    let id: String
    let subjectId: String
    let date: Date
    let logForm: RLMLogForm
    let files: [FilesResponseModel.File]

    private enum CodingKeys: String, CodingKey {
        case id
        case subjectId
        case date
        case logForm = "log"
        case files
    }

    init(form: RLMLogForm, storage: ImageStorageService) {
        self.id = newUUID
        guard let subjectId = form.subject?.id else {
            fatalError()
        }
        self.subjectId = subjectId
        self.date = Date()
        self.logForm = form

        // files array used only when receive response from server
        self.files = .init()
    }

}


extension LogFormAPIModel: Decodable {

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(String.self, forKey: .id)
        subjectId = try container.decode(String.self, forKey: .subjectId)

        // TODO: ????
        let formatter = Date.yearMonthDayFormatter
        guard let date = formatter.date(from: try container.decode(String.self, forKey: .date)) else {
            DDLogError("JSON DECODING ERROR: Invalid date format")
            fatalError("JSON DECODING ERROR: Invalid date format")
        }
        self.date = date

        logForm = try container.decode(RLMLogForm.self, forKey: .logForm)
        files = try container.decode([FilesResponseModel.File].self, forKey: .files)
    }
}


extension LogFormAPIModel: MultipartEncodable {

    var formData: [Moya.MultipartFormData] {
        var data = [Moya.MultipartFormData]()

        if let value = id.data(using: .utf8) {
            data.append(.init(provider: .data(value), name: CodingKeys.id.rawValue))
        }

        do {
            let formJson = try JSONEncoder().encode(logForm)
            data.append(.init(provider: .data(formJson), name: CodingKeys.logForm.rawValue))
        } catch {
            DDLogError("JSON Encoding error = \(error)")
            fatalError("JSON Encoding error = \(error)")
        }

        if let value = Date.yearMonthDayFormatter.string(from: Date()).data(using: .utf8) {
            data.append(.init(provider: .data(value), name: CodingKeys.date.rawValue))
        }

        let storage = ImageStorageService()
        logForm.rows.compactMap({ $0.photo }).forEach({
            if let url = storage.imageURL(name: $0.id) {
                data.append(.init(provider: .file(url), name: $0.id))
            }
        })

        return data
    }
}
