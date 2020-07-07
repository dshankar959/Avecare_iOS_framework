import UIKit
import Photos


class FullScreenPhotoController: UIViewController, UIScrollViewDelegate {

    @IBAction func downloadPhotoPressed(_ sender: UIButton) {
        if let image = image {
            UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
        }
    }
    @IBAction func donePressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }

    var image: UIImage? = nil
    @IBOutlet weak var photoView: UIImageView!
    var sessionService: ValidateSessionProtocol! = ValidateSessionMockService()

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let image = self.image {
            photoView.image = image
        }
    }

    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
       return self.photoView
    }

    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {

        if error != nil {
            let ac = UIAlertController(title: NSLocalizedString("gallery_permission", comment: ""), message: NSLocalizedString("gallery_permission_text", comment: ""), preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: NSLocalizedString("barbutton_title_cancel", comment: ""), style: .cancel))
            ac.addAction(UIAlertAction(title: NSLocalizedString("settings_action_title", comment: ""), style: .default, handler: { action in
                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
            }))
            present(ac, animated: true)
        } else {

            let ac = UIAlertController(title: NSLocalizedString("saved_title", comment: ""), message: NSLocalizedString("image_has_been_saved_message", comment: ""), preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: NSLocalizedString("alert_ok", comment: ""), style: .default))
            present(ac, animated: true)
        }

    }

}
