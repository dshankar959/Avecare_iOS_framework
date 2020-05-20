import Foundation
import CocoaLumberjack



struct SubjectsAPIService {

    static func publishDailyLog(log: DailyFormAPIModel, completion: @escaping (Result<FilesResponseModel, AppError>) -> Void) {
        apiProvider.request(.subjectPublishDailyLog(request: log)) { result in
            switch result {
            case .success(let response):
                do {
                    let mappedResponse = try response.map(FilesResponseModel.self)
                    completion(.success(mappedResponse))
                } catch {
                    DDLogError("JSON MAPPING ERROR = \(error)")
                    completion(.failure(JSONError.failedToMapData.message))
                }
            case .failure(let error):
                completion(.failure(getAppErrorFromMoya(with: error)))
            }
        }
    }

}
