import UIKit



private class Closure {

    let closure: () -> Void

    init(attachTo: AnyObject, closure: @escaping () -> Void) {
        self.closure = closure
        objc_setAssociatedObject(attachTo, "[\(arc4random())]", self, .OBJC_ASSOCIATION_RETAIN)
    }

    @objc func invoke() {
        closure()
    }

}


extension UIControl {

    func addAction(for controlEvents: Event = .primaryActionTriggered, action: @escaping () -> Void) {
        let sleeve = Closure(attachTo: self, closure: action)
        addTarget(sleeve, action: #selector(Closure.invoke), for: controlEvents)
    }

}


extension UIBarButtonItem {

    public convenience init(title: String?, style: UIBarButtonItem.Style, action: (() -> Void)?) {
        self.init()
        self.title = title
        self.style = style
        if let action = action {
            let sleeve = Closure(attachTo: self, closure: action)
            self.target = sleeve
            self.action = #selector(Closure.invoke)
        }
    }

}
