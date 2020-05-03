import Foundation
import UIKit
import BSImagePicker
import Photos

protocol StoriesDataProviderDelegate: UIViewController {
    func didUpdateModel(at indexPath: IndexPath, details: Bool)
}

protocol StoriesDataProvider: class {
    var delegate: StoriesDataProviderDelegate? { get set }
    var numberOfRows: Int { get }
    func model(for indexPath: IndexPath) -> StoriesTableViewCellModel
    func setSelected(_ isSelected: Bool, at indexPath: IndexPath)
    func form(at indexPath: IndexPath) -> Form
}

class DefaultStoriesDataProvider: StoriesDataProvider {

    private var lastSelectedIndexPath: IndexPath?
    var delegate: StoriesDataProviderDelegate?

    var dataSource: [StoriesTableViewCellModel] = [
        StoriesTableViewCellModel(title: nil, date: Date(), details: nil, photo: nil, photoCaption: nil),

        StoriesTableViewCellModel(title: "Colouring and Fine Motors Skills Development", date: Date(),
                details: "1" + R.string.placeholders.lorem_large(), photo: R.image.placeholderImage1(),
                photoCaption: "photo caption 1"),

        StoriesTableViewCellModel(title: "Language Skills in the Classroom and at Home", date: Date(),
                details: "2" + R.string.placeholders.lorem_large(), photo: R.image.placeholderImage2(),
                photoCaption: "photo caption 2"),

        StoriesTableViewCellModel(title: "Finger Painting - Classic Activities are Still Big Hits", date: Date(),
                details: "3" + R.string.placeholders.lorem_large(), photo: R.image.placeholderImage3(),
                photoCaption: "photo caption 3"),

        StoriesTableViewCellModel(title: "Team Building Play", date: Date(),
                details: "4" + R.string.placeholders.lorem_large(), photo: R.image.placeholderImage4(),
                photoCaption: "photo caption 4"),

        StoriesTableViewCellModel(title: "Our Little Artists with Big Imaginations", date: Date(),
                details: "5" + R.string.placeholders.lorem_large(), photo: R.image.placeholderImage5(),
                photoCaption: "photo caption 5"),

        StoriesTableViewCellModel(title: "Lorem ipsum dolor sit amet, consectetur adipiscing elit", date: Date(),
                details: "6" + R.string.placeholders.lorem_large(), photo: R.image.placeholderImage6(),
                photoCaption: "photo caption 6")
    ]

    var numberOfRows: Int {
        return dataSource.count
    }

    func model(for indexPath: IndexPath) -> StoriesTableViewCellModel {
        return dataSource[indexPath.row]
    }

    func setSelected(_ isSelected: Bool, at indexPath: IndexPath) {
        if isSelected {
            if let last = lastSelectedIndexPath {
                if last != indexPath {
                    // deselect
                    dataSource[last.row].isSelected = false
                    delegate?.didUpdateModel(at: last, details: true)
                } else {
                    // already selected
                    return
                }
            }
            dataSource[indexPath.row].isSelected = isSelected
            lastSelectedIndexPath = indexPath
            delegate?.didUpdateModel(at: indexPath, details: true)
        } else {
            guard let last = lastSelectedIndexPath, last == indexPath else {
                return
            }
            dataSource[last.row].isSelected = false
            delegate?.didUpdateModel(at: last, details: true)
        }
    }

    func form(at indexPath: IndexPath) -> Form {
        let titleFont: UIFont = .systemFont(ofSize: 36)
        let subtitleFont: UIFont = .systemFont(ofSize: 14)

        let action = FormPhotoViewModel.Action(onTextChange: { [weak self] view, textValue in
            self?.dataSource[indexPath.row].photoCaption = textValue
        }, onPhotoTap: { [weak self] view in
            self?.showImagePicker(from: view, at: indexPath)
        })

        return Form(viewModels: [
            FormTextViewModel(font: titleFont, placeholder: "Type Your Story Title Here",
                    value: dataSource[indexPath.row].title, onChange: { [weak self] _, textValue in
                self?.dataSource[indexPath.row].title = textValue
                self?.delegate?.didUpdateModel(at: indexPath, details: false)
            }),

            FormLabelViewModel.subtitle("Last saved - Jan 5, 7:16 AM")
                    .inset(by: UIEdgeInsets(top: 20, left: 0, bottom: 20, right: 0)),

            FormTextViewModel(font: subtitleFont, placeholder: "Begin typing here.",
                    value: dataSource[indexPath.row].title, onChange: { [weak self] _, textValue in
                self?.dataSource[indexPath.row].details = textValue
            }),

            FormPhotoViewModel(photo: dataSource[indexPath.row].photo,
                    caption: dataSource[indexPath.row].photoCaption,
                    placeholder: "Photo caption goes here.", action: action)
                    .inset(by: UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0))
        ])
    }
}

extension DefaultStoriesDataProvider {
    func showImagePicker(from view: FormPhotoView, at indexPath: IndexPath) {
        let imagePicker = ImagePickerController()
        imagePicker.settings.selection.max = 1

        delegate?.presentImagePicker(imagePicker, select: nil, deselect: nil, cancel: nil, finish: { (assets) in
            guard let asset = assets.first else {
                return
            }

            let size = 375 * UIScreen.main.scale
            PHImageManager.default().requestImage(for: asset, targetSize: CGSize(width: size, height: size),
                    contentMode: .aspectFit, options: nil) { [weak self] (image, _) in
                self?.dataSource[indexPath.row].photo = image
                view.photoImageView.image = image
                self?.delegate?.didUpdateModel(at: indexPath, details: false)
            }
            // User finished selection assets.
        })

    }
}
