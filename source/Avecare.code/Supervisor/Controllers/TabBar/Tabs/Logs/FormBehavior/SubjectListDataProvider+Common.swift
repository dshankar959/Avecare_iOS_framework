import UIKit



extension SubjectListDataProvider {

    func defaultToolbarView(onDone: (() -> Void)?, onCancel: (() -> Void)?) -> UIToolbar {
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        toolbar.barStyle = .default

        toolbar.items = [
            UIBarButtonItem(title: "Cancel", style: .plain, action: onCancel),
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(title: "Done", style: .plain, action: onDone)
        ]

        return toolbar
    }

}
