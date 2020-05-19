import Foundation
import UIKit



protocol StoriesDetailsDataSource {
    func viewModels() -> [AnyCellViewModel]
}

struct StoriesDetails: StoriesDetailsDataSource {
    struct Photo {
        let image: UIImage
        let caption: String?
    }
    let title: String?
    let description: String?
    let photo: Photo?

    func viewModels() -> [AnyCellViewModel] {
        var models = [AnyCellViewModel]()

        if let title = title, let description = description {
            models.append(StoriesDetailsTitleViewModel(title: title, description: description, date: Date()))
        }

        if let photo = photo {
            models.append(StoriesDetailsPhotoViewModel(image: photo.image, description: photo.caption))
        }

        return models
    }

}


class StoriesDetailsViewController: UIViewController {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var stackView: UIStackView!

    var details: StoriesDetailsDataSource?

    override func viewDidLoad() {
        super.viewDidLoad()

        if let details = details {
            setViews(details.viewModels())
        }

    }
}

extension StoriesDetailsViewController {
    func addView<T: CellViewModel>(with model: T) -> T.CellType {
        let view = model.buildView()
        stackView.addArrangedSubview(view)
        return view as! T.CellType
    }

    func setViews(_ models: [AnyCellViewModel]) {
        stackView.arrangedSubviews.forEach({ $0.removeFromSuperview() })
        for viewModel in models {
            let view = viewModel.buildView()
            stackView.addArrangedSubview(view)
        }
    }
}
