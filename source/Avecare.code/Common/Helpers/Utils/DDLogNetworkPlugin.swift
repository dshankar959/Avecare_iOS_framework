//
// For use with Moya framework and mainly in #DEBUG (!APPSTORE) builds.
//
// Logs network activity (outgoing requests and incoming responses).
// Tweaked to work with 'CocoaLumberjack' custom formatter so that its ouput also reaches the log files.
//

import Foundation
import Moya
import CocoaLumberjack



public final class DDLogNetworkPlugin: PluginType {
    fileprivate let output: (_ items: Any...) -> Void
    fileprivate let requestDataFormatter: ((Data) -> (String))?
    fileprivate let responseDataFormatter: ((Data) -> (Data))?

    // A Boolean value determing whether response body data should be logged.
    public let isVerbose: Bool
    public let cURL: Bool

    // Initializes the plugin.
    public init(verbose: Bool = false,
                cURL: Bool = false,
                output: ((_ items: Any...) -> Void)? = nil,
                requestDataFormatter: ((Data) -> (String))? = nil,
                responseDataFormatter: ((Data) -> (Data))? = nil) {
        self.cURL = cURL
        self.isVerbose = verbose
        self.output = output ?? DDLogNetworkPlugin.log
        self.requestDataFormatter = requestDataFormatter
        self.responseDataFormatter = responseDataFormatter
    }

    public func willSend(_ request: RequestType, target: TargetType) {
        #if !APPSTORE
        if let request = request as? CustomDebugStringConvertible, cURL {
            output(request.debugDescription)
            return
        }
        outputItems(logNetworkRequest(request.request as URLRequest?))
        #endif
    }

    public func didReceive(_ result: Result<Moya.Response, MoyaError>, target: TargetType) {
        #if !APPSTORE
        if case .success(let response) = result {
            outputItems(logNetworkResponse(response.response, data: response.data, target: target))
        } else {
            outputItems(logNetworkResponse(nil, data: nil, target: target))
        }
        #endif
    }

    fileprivate func outputItems(_ items: [String]) {
        #if !APPSTORE
        if isVerbose {
            items.forEach { output($0) }
        } else {
            output(items)
        }
        #endif
    }
}


#if !APPSTORE
private extension DDLogNetworkPlugin {

    func format(identifier: String, message: String) -> String {
        return "\(identifier): \(message)"
    }

    func logNetworkRequest(_ request: URLRequest?) -> [String] {

        var output = [String]()

        output += [format(identifier: "Request", message: request?.description ?? "(invalid request)")]

        if let headers = request?.allHTTPHeaderFields {
            output += [format(identifier: "Request Headers", message: headers.description)]
        }

        if let bodyStream = request?.httpBodyStream {
            output += [format(identifier: "Request Body Stream", message: bodyStream.description)]
        }

        if let httpMethod = request?.httpMethod {
            output += [format(identifier: "HTTP Request Method", message: httpMethod)]
        }

        if let body = request?.httpBody,
            let stringOutput = requestDataFormatter?(body) ?? String(data: body, encoding: .utf8),
            isVerbose {
                output += [format(identifier: "Request Body", message: stringOutput)]
        }

        return output
    }

    func logNetworkResponse(_ response: HTTPURLResponse?, data: Data?, target: TargetType) -> [String] {
        guard response != nil else {
           return [format(identifier: "Response", message: "Received empty network response for \(target).")]
        }

        var output = [String]()
        output += [format(identifier: "Response", message: "")]

        if let data = data,
           let stringData = String(data: responseDataFormatter?(data) ?? data, encoding: String.Encoding.utf8),
           isVerbose {
              output += [stringData]
        }

        return output
    }
}
#endif


fileprivate extension DDLogNetworkPlugin {
    static func log(items: Any...) {
        #if !APPSTORE

            for item in items {
                let message = item as? String ?? nil
                if let msg = message {
                    if let data = msg.data(using: .utf8) {
                        do {
                            let rawJSON = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                            DDLogVerbose("JSON: \(rawJSON)\n")
                        } catch {
                            DDLogVerbose(msg)
                        }
                    }
                }
            }

        #endif
    }

}
