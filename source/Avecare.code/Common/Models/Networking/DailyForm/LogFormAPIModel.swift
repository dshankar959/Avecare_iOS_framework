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


    init(form: RLMLogForm, storage: DocumentService) {
        self.id = form.id
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
        do {
            let container = try decoder.container(keyedBy: CodingKeys.self)

            id = try container.decode(String.self, forKey: .id)
            subjectId = try container.decode(String.self, forKey: .subjectId)

            let dateString = try container.decode(String.self, forKey: .date)
            guard let date = Date.dateFromLogFormString(dateString) else {
                DDLogError("JSON Decoding error: Invalid date format")
                fatalError("JSON Decoding error: Invalid date format")
            }
            self.date = date

            logForm = try container.decode(RLMLogForm.self, forKey: .logForm)
            files = try container.decode([FilesResponseModel.File].self, forKey: .files)
        } catch {
            DDLogError("JSON Decoding error = \(error)")
            fatalError("JSON Decoding error = \(error)")
        }
    }
}


extension LogFormAPIModel: MultipartEncodable {

    var formData: [Moya.MultipartFormData] {
        var data = [Moya.MultipartFormData]()

        if let value = id.data(using: .utf8) {
            data.append(.init(provider: .data(value), name: CodingKeys.id.rawValue))
        }

        if let value = Date.logFormStringFromDate(Date()).data(using: .utf8) {
            data.append(.init(provider: .data(value), name: CodingKeys.date.rawValue))
        }

        do {
            // Sanitize RLMLogForm object to just the rows for the API.
            let logFormRows = logForm.rows.detached()
            let encoder = JSONEncoder()
            let formRows = try encoder.encode(["rows": logFormRows])   // dict.

            data.append(.init(provider: .data(formRows), name: CodingKeys.logForm.rawValue))
        } catch {
            DDLogError("JSON Encoding error = \(error)")
            fatalError("JSON Encoding error = \(error)")
        }

        let storage = DocumentService()
        logForm.rows.compactMap({ $0.photo }).forEach({
            if let url = storage.fileURL(name: $0.id, type: "jpg") {
                data.append(.init(provider: .file(url), name: $0.id))
            }
        })

        return data
    }
}
