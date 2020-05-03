import Foundation
import CocoaLumberjack
import Moya

extension AvecareAPI {

    // MARK: - JSON stubbed responses  (Javascript escaped)
    // https://www.freeformatter.com/json-formatter.html#ad-output

    var sampleData: Data {
        DDLogDebug("sampleData...  { Stubbed response }")

        return "default data".utf8Encoded

    }

}
