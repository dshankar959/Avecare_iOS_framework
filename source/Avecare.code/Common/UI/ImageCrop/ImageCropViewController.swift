import UIKit
import CocoaLumberjack
import CropPickerView



class ImageCropViewController: UIViewController {

    @IBOutlet weak var cropPickerView: CropPickerView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var finishButton: UIButton!

    var image: UIImage? {
        didSet {
            if cropPickerView != nil {
                cropPickerView.image = image
            }
        }
    }

    private var resultImage: UIImage?

    var onCancel: (() -> Void)?
    var onFinish: ((_ image: UIImage?) -> Void)?


    // MARK: -
    override func viewDidLoad() {
        super.viewDidLoad()

        if let image = image {
            cropPickerView.image = image
        }

        cancelButton.setTitle(NSLocalizedString("barbutton_title_cancel", comment: ""), for: .normal)
        finishButton.setTitle(NSLocalizedString("barbutton_title_done", comment: ""), for: .normal)
    }


    @IBAction func cancelButtonTouched(_ sender: UIButton) {
        if let onCancel = onCancel {
            onCancel()
        }
        dismiss(animated: true, completion: nil)
    }


    @IBAction func finishButtonTouched(_ sender: UIButton) {
        cropPickerView.crop { (error, image, crop) in
            if let error = error as NSError? {
                DDLogError(error.localizedDescription)
                self.onFinish?(nil)
            } else {
                self.onFinish?(image)
            }
            self.dismiss(animated: true, completion: nil)
        }
    }
}



extension UIViewController {

    func presentCropPicker(_ cropPicker: ImageCropViewController,
                           animated: Bool = true,
                           cancel: (() -> Void)?,
                           finish: ((UIImage?) -> Void)?,
                           completion: (() -> Void)? = nil) {
        cropPicker.onCancel = cancel
        cropPicker.onFinish = finish

        self.present(cropPicker, animated: animated, completion: completion)
    }

}
