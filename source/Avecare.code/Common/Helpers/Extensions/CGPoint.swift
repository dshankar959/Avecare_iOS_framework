import UIKit

extension CGPoint {

    func move(x: CGFloat) -> CGPoint {
        return CGPoint(x: self.x + x, y: y)
    }

    func move(y: CGFloat) -> CGPoint {
        return CGPoint(x: x, y: self.y + y)
    }

}
