import Foundation
import UIKit
import SnapKit

extension AnyCellViewModel {
    func inset(by insets: UIEdgeInsets) -> InsetFormViewModel {
        return InsetFormViewModel(insets: insets, nestedViewModel: self)
    }
}

struct InsetFormViewModel: AnyCellViewModel {
     static var cellType: UIView.Type {
         return UIView.self
     }

    let insets: UIEdgeInsets
    let nestedViewModel: AnyCellViewModel

    func setup(cell: UIView) {

    }

    func buildView() -> UIView {
        let view = UIView()
        let content = nestedViewModel.buildView()
        view.addSubview(content)
        content.snp.makeConstraints { maker in
            maker.edges.equalToSuperview().inset(insets)
        }
        return view
    }
}
