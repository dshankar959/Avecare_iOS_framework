import Foundation
import UIKit

@IBDesignable class TextField: UITextField {
    @IBInspectable var insetX: CGFloat = 6 {
       didSet {
         layoutIfNeeded()
       }
    }

    @IBInspectable var insetY: CGFloat = 6 {
       didSet {
         layoutIfNeeded()
       }
    }

    override class func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
    }

    // placeholder position
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: insetX, dy: insetY)
    }

    // text position
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: insetX, dy: insetY)
    }

    @IBAction func securitySwitchAction(sender: UIButton) {
        sender.isSelected = !self.isSecureTextEntry
        self.isSecureTextEntry = !self.isSecureTextEntry
    }
}
