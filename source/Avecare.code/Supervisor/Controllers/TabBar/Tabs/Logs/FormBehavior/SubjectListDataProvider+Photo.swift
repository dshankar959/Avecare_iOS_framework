import UIKit
import BSImagePicker
import Photos
import CocoaLumberjack
import CropPickerView


extension SubjectDetailsPhotoViewModel {

    init(row: RLMLogPhotoRow, isEditable: Bool, storage: DocumentService) {
        title = row.title
        note = row.text

        if let localURL = storage.fileURL(name: row.id, type: "jpg") {
            image = localURL
        }
        self.isEditable = isEditable
    }
}


extension SubjectListDataProvider {

    func viewModel(for row: RLMLogPhotoRow,
                   editable: Bool,
                   at indexPath: IndexPath,
                   for rowIndex: Int,
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
            self?.showImagePicker(from: view, row: row, for: rowIndex, updateCallback: updateCallback)
        })

        viewModel.onRemoveCell = { [weak self] in
            if let subject = self?.selectedSubject {
                RLMLogForm.writeTransaction {
                    subject.todayForm.rows.remove(at: rowIndex)
                }
                self?.delegate?.didUpdateModel(at: indexPath)
            }
        }

        return viewModel
    }


    private func showImagePicker(from view: SubjectDetailsPhotoView,
                                 row: RLMLogPhotoRow,
                                 for rowIndex: Int,
                                 updateCallback: @escaping (Date) -> Void) {

        let imagePicker = ImagePickerController()
        imagePicker.settings.selection.max = 1

        delegate?.presentImagePicker(imagePicker, select: nil, deselect: nil, cancel: nil, finish: { (assets) in
            guard let asset = assets.first else {
                return
            }

            PHImageManager.default().requestImage(for: asset,
                                                  targetSize: PHImageManagerMaximumSize,
                                                  contentMode: .aspectFit,
                                                  options: nil) { [weak self] (image, info) in

                guard !((info?[PHImageResultIsDegradedKey] as? Bool) ?? false),
                    let image = image, let service = self?.imageStorageService else {
                        return
                }

                let cropPicker = ImageCropViewController()
                cropPicker.modalPresentationStyle = .currentContext
                cropPicker.image = image

                self?.delegate?.presentCropPicker(cropPicker, cancel: nil, finish: { image in
                    guard let image = image else {
                        return
                    }
                    // remove previous local image
                    if let fileURL = service.fileURL(name: row.id, type: "jpg") {
                        do {
                            try service.removeFile(at: fileURL)
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
                })
            }
        })
    }
}
