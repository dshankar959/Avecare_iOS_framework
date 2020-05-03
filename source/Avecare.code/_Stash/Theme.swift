import UIKit

enum Theme: Int {
    case `default`
    case slateGray

    //  private enum Keys {
    //    static let selectedTheme = "SelectedTheme"
    //  }

    //  static var current: Theme {
    //    let storedTheme = UserDefaults.standard.integer(forKey: Keys.selectedTheme)
    //    return Theme(rawValue: storedTheme) ?? .default
    //  }

    var mainColor: UIColor {
        switch self {
        case .slateGray:
            return UIColor(hex: "708090")

        case .default:
            return .black
        }
    }

    var barStyle: UIBarStyle {
        switch self {
        case .slateGray, .default:
            return .default
        }
    }

    var backgroundColor: UIColor {
        switch self {
        case .slateGray, .default:
            return UIColor.white
        }
    }

    var textColor: UIColor {
        switch self {
        case .slateGray, .default:
            return UIColor.black
        }
    }

    func apply() {

//        UIApplication.shared.delegate?.window??.tintColor = mainColor
        UIApplication.shared.delegate?.window??.tintColor = textColor

        UINavigationBar.appearance().barStyle = barStyle
        UINavigationBar.appearance().tintColor = mainColor

        UITabBar.appearance().barStyle = barStyle
        UITabBar.appearance().tintColor = mainColor

        UITableViewCell.appearance().backgroundColor = backgroundColor

//        UILabel.appearance(whenContainedInInstancesOf: [UITableViewCell.self]).textColor = textColor
    }
}
