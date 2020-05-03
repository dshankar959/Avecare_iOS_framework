import UIKit

extension UIImage {

    func tintWithColor(color: UIColor) -> UIImage {
        UIGraphicsBeginImageContext(self.size)
        let context = UIGraphicsGetCurrentContext()!

        // flip the image
        context.scaleBy(x: 1.0, y: -1.0)
        context.translateBy(x: 0.0, y: -self.size.height)

        // multiply blend mode
        context.setBlendMode(.multiply)

        let rect = CGRect(origin: CGPoint(x: 0, y: 0), size: self.size)
        context.clip(to: rect, mask: self.cgImage!)
        color.setFill()
        context.fill(rect)

        // create uiimage
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage!
    }

}

extension UIImageView {
    func tintWithColor(color: UIColor) {
        self.image = self.image?.tintWithColor(color: color)
    }

}
