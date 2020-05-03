import UIKit

extension UIDevice {
    var deviceOrientation: UIDeviceOrientation {
        var currentOrientation = UIDevice.current.orientation

        if currentOrientation == .unknown ||
           currentOrientation == .faceUp  ||
           currentOrientation == .faceDown {
            switch UIApplication.shared.statusBarOrientation {
            case .landscapeLeft:
                currentOrientation = UIDeviceOrientation.landscapeLeft
            case .landscapeRight:
                currentOrientation = UIDeviceOrientation.landscapeRight
            case .portraitUpsideDown:
                currentOrientation = UIDeviceOrientation.portraitUpsideDown
            case .portrait:
                fallthrough
            case .unknown:
                fallthrough
            default:
                currentOrientation = UIDeviceOrientation.portrait
            }
        }

        return currentOrientation
    }

}
