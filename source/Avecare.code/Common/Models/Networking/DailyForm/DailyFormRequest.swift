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
