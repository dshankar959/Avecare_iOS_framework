import UIKit

struct MarginFormViewModel: AnyCellViewModel {
    private(set) static var cellType = UIView.self

    let height: CGFloat

    func setup(cell: UIView) {

    }

    func buildView() -> UIView {
        let view = UIView()

        view.snp.makeConstraints { maker in
            maker.height.equalTo(height)
        }

        return view
    }
}
