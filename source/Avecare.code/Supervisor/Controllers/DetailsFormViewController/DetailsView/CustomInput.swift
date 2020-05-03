import Foundation
import UIKit

protocol CustomResponder: UIResponder {
    var customInputView: UIView? { get set }
    var customInputAccessoryView: UIView? { get set }
    func becomeFirstResponder(inputView: UIView?, accessoryView: UIView?)
}

protocol CustomResponderProvider {
    var customResponder: CustomResponder? { get }
}
