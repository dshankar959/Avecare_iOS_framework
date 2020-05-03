import Foundation
import UIKit

public protocol ApplicationService: UIApplicationDelegate {

}

public extension ApplicationService {

    var window: UIWindow? {
        return UIApplication.shared.delegate?.window as? UIWindow
    }

}
