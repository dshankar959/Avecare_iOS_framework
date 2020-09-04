import UIKit

class LogFormCellView: BaseXibView {

    enum SwipingState {
        case initial
        case swiped
    }

    private var isLoaded = false
    private var isSwiped = false
    private var coverView: UIView?
    private var removeButton: UIButton?
    private var backgroundView: UIView?

    private let removeButtonWidth: CGFloat = 100.0
    private var spacerWidth: CGFloat {
        return self.frame.width * 0.05
    }
    private var frameHeight: CGFloat {
        return self.frame.height
    }
    private var coverViewOriginX: CGFloat {
        return spacerWidth - removeButtonWidth
    }
    private var removeButtonOriginX: CGFloat {
        return self.frame.width - spacerWidth - 2 * removeButtonWidth
    }

    var swipeToDeleteEnabled = false
    var onRemoveCell: (() -> Void)?

    override func setup() {
        super.setup()

        DispatchQueue.main.async { [weak self] in
            self?.setupSwipeToDeleteViews()
        }

        if !isLoaded {
            let pan = UIPanGestureRecognizer(target: self, action: #selector(managePan))
            pan.delegate = self
            self.addGestureRecognizer(pan)

            NotificationCenter.default.addObserver(self, selector: #selector(otherCellSelected(note:)), name: .swipedBeginsInLogForm, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(didRotate(note:)), name: UIDevice.orientationDidChangeNotification, object: nil)

            isLoaded = true
        }
    }

    private func setupSwipeToDeleteViews() {
        if coverView == nil {
            coverView = UIView(frame: CGRect(x: coverViewOriginX,
                                             y: 0,
                                             width: removeButtonWidth,
                                             height: frameHeight))
            coverView!.backgroundColor = R.color.background()
            addSubview(coverView!)
            coverView!.isHidden = true
        } else {
            coverView!.frame = CGRect(x: coverViewOriginX,
                                      y: 0,
                                      width: removeButtonWidth,
                                      height: frameHeight)
        }

        if removeButton == nil {
            removeButton = UIButton(frame: CGRect(x: removeButtonOriginX,
                                                  y: 0,
                                                  width: removeButtonWidth,
                                                  height: frameHeight))
            removeButton!.backgroundColor = .red
            removeButton!.setTitle(NSLocalizedString("log_row_delete", comment: ""), for: .normal)
            removeButton!.addAction(for: .touchUpInside) { [weak self] in
                self?.removeRow()
            }
            addSubview(removeButton!)
            sendSubviewToBack(removeButton!)
            removeButton!.isHidden = true
        } else {
            removeButton!.frame = CGRect(x: removeButtonOriginX,
                                         y: 0,
                                         width: removeButtonWidth,
                                         height: frameHeight)
        }

        if backgroundView == nil {
            backgroundView = UIView(frame: CGRect(x: 0,
                                                  y: 0,
                                                  width: removeButtonOriginX,
                                                  height: frameHeight))
            backgroundView!.backgroundColor = .red
            addSubview(backgroundView!)
            sendSubviewToBack(backgroundView!)
            backgroundView!.isHidden = true
        } else {
            backgroundView!.frame = CGRect(x: 0,
                                           y: 0,
                                           width: removeButtonOriginX,
                                           height: frameHeight)
        }
    }

    @objc private func otherCellSelected(note: Notification) {
        restoreViews()
    }

    @objc private func didRotate(note: Notification) {
        setupSwipeToDeleteViews()
        restoreViews()
    }

    private func restoreViews() {
        if isSwiped {
            sendSubviewToBack(removeButton!)
            setViews(for: .initial)
        }
    }

    @objc private func managePan(_ gesture: UIPanGestureRecognizer) {
        if swipeToDeleteEnabled {
            if coverView!.frame.height == 0 { // Check if frame shrunk to 0 when views are created
                setupSwipeToDeleteViews()
            }
            if let scrollView = superview?.superview?.superview as? UIScrollView {
                // Determine scroll speed
                let scrollSpeed = scrollView.panGestureRecognizer.velocity(in: scrollView.superview)

                // Prevent swiping when scrolling
                let isScrolling: Bool
                let translateX: CGFloat
                if scrollSpeed.y < 100, scrollSpeed.y > -100 {
                    isScrolling = false
                    translateX = gesture.translation(in: self.superview).x
                } else {
                    isScrolling = true
                    translateX = 0
                }

                switch gesture.state {
                case .began:
                    if !isSwiped {
                        NotificationCenter.default.post(name: .swipedBeginsInLogForm, object: nil)

                        coverView!.isHidden = false
                        removeButton!.isHidden = false
                        backgroundView!.isHidden = false
                    } else {
                        sendSubviewToBack(removeButton!)
                    }
                case .changed:
                    if !isSwiped, !isScrolling, translateX < 0 {
                        if scrollView.isScrollEnabled {
                            scrollView.isScrollEnabled = false
                        }
                        translateViews(for: translateX)
                    } else if isSwiped {
                        if translateX < removeButtonWidth {
                            translateViews(for: translateX - removeButtonWidth)
                        } else {
                            translateViews(for: 0)
                        }
                    }
                case .cancelled:
                    setViews(for: .initial)
                    scrollView.isScrollEnabled = true
                case .ended:
                    scrollView.isScrollEnabled = true
                    if (!isSwiped && translateX < removeButtonWidth - (frame.width - removeButtonWidth) * 0.9) ||
                        (isSwiped && translateX < 2 * removeButtonWidth - (frame.width - removeButtonWidth) * 0.9) {
                        removeRow()
                    } else {
                        if (!isSwiped && translateX < -removeButtonWidth / 2) ||
                            (isSwiped && translateX < removeButtonWidth / 2 ) {
                            setViews(for: .swiped)
                        } else {
                            setViews(for: .initial)
                        }
                    }
                default:
                    break
                }
            }
        }
    }

    private func removeRow() {
        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            self?.isHidden = true
            self?.coverView!.isHidden = true
            self?.removeButton!.isHidden = true
            self?.backgroundView!.isHidden = true
        }) { [weak self] isFinished in
            if isFinished {
                self?.coverView!.removeFromSuperview()
                self?.coverView = nil
                self?.removeButton!.removeFromSuperview()
                self?.removeButton = nil
                self?.backgroundView!.removeFromSuperview()
                self?.backgroundView = nil

                self?.onRemoveCell?()
            }
        }
    }

    override func willMove(toSuperview newSuperview: UIView?) {
        if newSuperview == nil {
            // swiftlint:disable notification_center_detachment
            NotificationCenter.default.removeObserver(self)
            // swiftlint:enable notification_center_detachment
        }
    }

    // MARK: - Helper method for swipe to delete

    private func setViews(for state: SwipingState) {
        switch state {
        case .initial:
            UIView.animate(withDuration: 0.3, animations: {
                self.translateViews(for: 0)
            }) { finished in
                self.coverView!.isHidden = true
                self.removeButton!.isHidden = true
                self.backgroundView!.isHidden = true

                self.isSwiped = false
            }

        case .swiped:
            UIView.animate(withDuration: 0.3, animations: {
                self.translateViews(for: -self.removeButtonWidth)
            }) { finished in
                self.bringSubviewToFront(self.removeButton!)
                self.isSwiped = true
            }
        }
    }

    private func translateViews(for translateX: CGFloat) {
        translateView(with: self, andOriginX: 0, for: translateX)
        translateView(with: coverView!, andOriginX: coverViewOriginX, for: -translateX)
        translateView(with: removeButton!, andOriginX: removeButtonOriginX, for: -translateX)
        translateView(with: backgroundView!, andOriginX: 0, for: -translateX)
    }

    private func translateView(with view: UIView, andOriginX originX: CGFloat, for translateX: CGFloat) {
        view.frame = CGRect(x: originX + translateX,
                            y: view.frame.origin.y,
                            width: view.frame.width,
                            height: view.frame.height)
    }
}

public extension Notification.Name {
    static let swipedBeginsInLogForm = Notification.Name("swipedBeginsInLogForm")
}

extension LogFormCellView: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
