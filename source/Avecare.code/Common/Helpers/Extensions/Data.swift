import Foundation



extension Data {

    func hexadecimalString() -> String {
        return self.reduce("") { $0 + String(format: "%02X", $1) }
    }

}


// Get index of enum with extension of String.
// https://stackoverflow.com/a/57430768/7599
extension CaseIterable where Self: Equatable {

    var index: Self.AllCases.Index! {
        return Self.allCases.firstIndex { self == $0 }
    }

}
