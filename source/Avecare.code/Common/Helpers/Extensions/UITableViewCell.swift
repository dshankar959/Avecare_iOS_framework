import UIKit

extension UITableViewCell {

    func removeBottomSeparator() {
        // Remove it if it's found.
        for view in self.subviews where String(describing: type(of: view)).hasSuffix("SeparatorView") {
            view.removeFromSuperview()
        }
    }

    func hideBottomSeparator(_ isHidden: Bool) {
        // Hide it if it's found.
        for view in self.subviews where String(describing: type(of: view)).hasSuffix("SeparatorView") {
            view.isHidden = isHidden
        }
    }

    func separatorView() -> UIView? {
        for view in self.subviews where String(describing: type(of: view)).hasSuffix("SeparatorView") {
            return view
        }
        return nil
    }

}
