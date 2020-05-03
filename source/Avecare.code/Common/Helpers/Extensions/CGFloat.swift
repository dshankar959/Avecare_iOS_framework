import UIKit

extension CGFloat {

    init?(string: String) {
        guard let number = NumberFormatter().number(from: string) else {
            return nil
        }

        self.init(number.floatValue)
    }

}
