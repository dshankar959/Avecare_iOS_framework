import Foundation
import UIKit
import BSImagePicker
import Photos

extension SubjectDetailsPhotoViewModel {
    init(row: RLMLogPhotoRow) {
        title = row.title
        note = row.text

        if let path = row.imageUrl {
            image = URL(string: path)
        }
    }
}

extension DefaultSubjectListDataProvider {
    func viewModel(for row: RLMLogPhotoRow, at indexPath: IndexPath) -> SubjectDetailsPhotoViewModel {
        var viewModel = SubjectDetailsPhotoViewModel(row: row)
        viewModel.action = .init(onTextChange: { view in
            row.writeTransaction {
                if view.textView.text.count > 0 {
                    row.text = view.textView.text
                } else {
                    row.text = nil
                }
            }
        }, onPhotoTap: { [weak self] view in
            self?.showImagePicker(from: view, row: row, at: indexPath)
        })
        return viewModel
    }

    private func showImagePicker(from view: SubjectDetailsPhotoView, row: RLMLogPhotoRow, at indexPath: IndexPath) {
        let imagePicker = ImagePickerController()
        imagePicker.settings.selection.max = 1

        delegate?.presentImagePicker(imagePicker, select: nil, deselect: nil, cancel: nil, finish: { (assets) in
            guard let asset = assets.first else {
                return
            }

            let size = 375 * UIScreen.main.scale
            PHImageManager.default().requestImage(for: asset,
                                                  targetSize: CGSize(width: size, height: size),
                                                  contentMode: .aspectFit,
                                                  options: nil) { image, _ in
                guard let image = image else {
                    return
                }
                let service = ImageStorageService(for: appSession.userProfile)

                // remove previous local image
                if let path = row.imageUrl, path.isFilePath, let filePath = URL(string: path) {
                    do {
                        try service.removeImage(at: filePath)
                    } catch {
                        print(error)
                    }
                }

                do {
                    // save image locally
                    let url = try service.saveImage(image)
                    // update database
                    row.writeTransaction {
                        row.imageUrl = url.absoluteString
                    }
                    // update UI
                    view.setImage(url)

                } catch {
                    print(error)
                }

            }
        })

    }
}
