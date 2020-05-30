import UIKit
import BSImagePicker
import Photos
import CocoaLumberjack



extension SubjectDetailsPhotoViewModel {

    init(row: RLMLogPhotoRow, isEditable: Bool, storage: ImageStorageService) {
        title = row.title
        note = row.text

        if let localURL = storage.imageURL(name: row.id) {
            image = localURL
        }
        self.isEditable = isEditable
    }

}


extension SubjectListDataProvider {

    func viewModel(for row: RLMLogPhotoRow,
                   editable: Bool,
                   at indexPath: IndexPath,
                   updateCallback: @escaping (Date) -> Void) -> SubjectDetailsPhotoViewModel {

        var viewModel = SubjectDetailsPhotoViewModel(row: row, isEditable: editable, storage: imageStorageService)

        viewModel.action = .init(onTextChange: { view in
            RLMLogPhotoRow.writeTransaction {
                if view.textView.text.count > 0 {
                    row.text = view.textView.text
                } else {
                    row.text = nil
                }
            }
            updateCallback(Date())
        }, onPhotoTap: { [weak self] view in
            self?.showImagePicker(from: view, row: row, at: indexPath, updateCallback: updateCallback)
        })

        return viewModel
    }


    private func showImagePicker(from view: SubjectDetailsPhotoView,
                                 row: RLMLogPhotoRow,
                                 at indexPath: IndexPath,
                                 updateCallback: @escaping (Date) -> Void) {

        let imagePicker = ImagePickerController()
        imagePicker.settings.selection.max = 1

        delegate?.presentImagePicker(imagePicker, select: nil, deselect: nil, cancel: nil, finish: { (assets) in
            guard let asset = assets.first else {
                return
            }

            // FIXME: setup size if needed
            let size = 375 * UIScreen.main.scale
            PHImageManager.default().requestImage(for: asset,
                                                  targetSize: CGSize(width: size, height: size),
                                                  contentMode: .aspectFit,
                                                  options: nil) { [weak self] image, info in

                guard !((info?[PHImageResultIsDegradedKey] as? Bool) ?? false),
                    let image = image, let service = self?.imageStorageService else {
                        return
                }
                // remove previous local image
                if let fileURL = service.imageURL(name: row.id) {
                    do {
                        try service.removeImage(at: fileURL)
                    } catch {
                        DDLogError("\(error)")
                    }
                }

                do {
                    // save image locally
                    let url = try service.saveImage(image, name: row.id)
                    // update form client date
                    updateCallback(Date())
                    // update UI
                    view.setImage(url)

                } catch {
                    DDLogError("\(error)")
                }
            }
        })

    }

}
