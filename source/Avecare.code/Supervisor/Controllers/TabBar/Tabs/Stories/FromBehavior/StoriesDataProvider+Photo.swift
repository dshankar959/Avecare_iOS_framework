import Foundation
import UIKit
import BSImagePicker
import Photos
import CocoaLumberjack

extension StoriesDataProvider {

    func photoViewModel(for story: RLMStory) -> FormPhotoViewModel {
        let isSubmitted = story.publishState != .local
        let photoRowAction = FormPhotoViewModel.Action(onTextChange: { [weak self] view, textValue in
            RLMStory.writeTransaction {
                story.photoCaption = textValue ?? ""
            }
            // update date, side menu row will be moved to 1st position
            self?.updateEditDate(for: story)
        }, onPhotoTap: { [weak self] view in
            self?.showImagePicker(from: view, for: story)
        })

        return FormPhotoViewModel(photoURL: story.photoURL(using: imageStorageService), caption: story.photoCaption,
                placeholder: "Photo caption goes here.", isEditable: !isSubmitted, action: photoRowAction)
    }

    func showImagePicker(from view: FormPhotoView, for story: RLMStory) {
        let imagePicker = ImagePickerController()
        imagePicker.settings.selection.max = 1

        delegate?.presentImagePicker(imagePicker, select: nil, deselect: nil, cancel: nil, finish: { (assets) in
            guard let asset = assets.first else {
                return
            }

            let size = 375 * UIScreen.main.scale
            PHImageManager.default().requestImage(for: asset, targetSize: CGSize(width: size, height: size),
                    contentMode: .aspectFit, options: nil) { [weak self] (image, info) in

                // skip low quality image callback
                guard !((info?[PHImageResultIsDegradedKey] as? Bool) ?? false),
                      let image = image, let service = self?.imageStorageService else {
                    return
                }

                // remove previous local image
                if let fileURL = service.imageURL(name: story.id) {
                    do {
                        try service.removeImage(at: fileURL)
                    } catch {
                        DDLogError("\(error)")
                    }
                }

                do {
                    // save image locally
                    _ = try service.saveImage(image, name: story.id)
                    // update from photo
                    view.photoImageView.image = image
                    // update date
                    // side menu row will be moved to 1st position
                    self?.updateEditDate(for: story)
                    // update photo on side list row
                    self?.delegate?.didUpdateModel(at: IndexPath(row: 0, section: 0), details: false)
                } catch {
                    DDLogError("\(error)")
                }
            }
        })

    }
}
