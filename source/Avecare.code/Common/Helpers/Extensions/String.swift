import Foundation
import UIKit
import CoreGraphics



extension String {

    static func randomAlphaNumericString(length: Int = 5) -> String {
        // create random numbers from 0 to 63
        // use random numbers as index for accessing characters from the symbols string
        // this limit is chosen because it is close to the number of possible symbols A-Z, a-z, 0-9
        // so the error rate for invalid indices is low
        let randomNumberModulo: UInt8 = 64

        // indices greater than the length of the symbols string are invalid
        // invalid indices are skipped
        let symbols = "ABCDEFGHIJKLMNPQRSTUVWXYZabcdefghijklmnpqrstuvwxyz123456789"

        var alphaNumericRandomString = ""

        let maximumIndex = symbols.count - 1

        while alphaNumericRandomString.count != length {
            let bytesCount = 1
            var randomByte: UInt8 = 0

            guard errSecSuccess == SecRandomCopyBytes(kSecRandomDefault, bytesCount, &randomByte) else {
                // fallback
                let randomString = newUUID
                let cleanString = randomString.replacingOccurrences(of: "-", with: "")
                let limitedLengthString = cleanString.prefix(length)
                return String(limitedLengthString)
            }

            let randomIndex = randomByte % randomNumberModulo

            // check if index exceeds symbols string length, then skip
            guard randomIndex <= maximumIndex else { continue }

            let symbolIndex = symbols.index(symbols.startIndex, offsetBy: Int(randomIndex))
            alphaNumericRandomString.append(symbols[symbolIndex])
        }

        return alphaNumericRandomString
    }

    var URLEscapedString: String {
        return self.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlHostAllowed)!
    }

    var utf8Encoded: Data {
        return data(using: .utf8)!
    }

    var isFilePath: Bool {
        return hasPrefix("file://")
    }

    var isWebLink: Bool {
        return hasPrefix("http://") || hasPrefix("https://")
    }

    // Remove substring between occurrences
    // https://stackoverflow.com/a/54114340/7599
    private func regExprOfDetectingStringsBetween(str1: String, str2: String) -> String {
        return "(?:\(str1))(.*?)(?:\(str2))"
    }

    func replacingOccurrences(from subString1: String, to subString2: String, with replacement: String) -> String {
        let regExpr = regExprOfDetectingStringsBetween(str1: subString1, str2: subString2)
        return replacingOccurrences(of: regExpr, with: replacement, options: .regularExpression)
    }

    // Trim all bracket parameters "(...)" from a function string.
    func removeBrackets() -> String {
        var strCopy = self

        if let startIndex = strCopy.firstIndex(of: "(") {
            let range = Range(uncheckedBounds: (lower: startIndex, upper: strCopy.endIndex))
            strCopy.removeSubrange(range)
            return strCopy.trimmingCharacters(in: .whitespacesAndNewlines)
        }

        return strCopy
    }


}



extension NSAttributedString {

    func withLineSpacing(_ spacing: CGFloat, centered: Bool = false) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(attributedString: self)
        let paragraphStyle = NSMutableParagraphStyle()

        paragraphStyle.lineBreakMode = .byTruncatingTail
        paragraphStyle.lineSpacing = spacing

        if centered {
            paragraphStyle.alignment = .center
        }

        attributedString.addAttribute(.paragraphStyle,
                                      value: paragraphStyle,
                                      range: NSRange(location: 0, length: string.count))

        return NSAttributedString(attributedString: attributedString)
    }

}
