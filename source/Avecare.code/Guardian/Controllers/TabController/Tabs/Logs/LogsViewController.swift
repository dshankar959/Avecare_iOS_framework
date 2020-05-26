import UIKit
import JTAppleCalendar



class LogsViewController: UIViewController {

    @IBOutlet weak var subjectSelectButton: UIButton!
    @IBOutlet weak var calendarView: JTACMonthView!
    @IBOutlet weak var selectedDateLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!

    let dataProvider = DefaultLogsDataProvider()
    lazy var slideInTransitionDelegate = SlideInPresentationManager()
    let subjectListDataProvider = DefaultSubjectListDataProvider()

    var filterDate: Date {
        calendarView.selectedDates.first?.startOfDay ?? Date().startOfDay
    }

    weak var subjectSelection: SubjectSelectionProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()
        subjectSelection = tabBarController as? GuardianTabBarController

        tableView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)

        calendarView.scrollDirection = .horizontal
        calendarView.scrollingMode = .nonStopToCell(withResistance: 0.5)
        calendarView.showsHorizontalScrollIndicator = false
        calendarView.scrollToDate(Date().previous(.sunday, includingTheDate: true), animateScroll: false)
        calendarView.selectDates([Date()])

        tableView.register(nibModels: [
            LogsOptionTableViewCellModel.self,
            LogsTimeDetailsTableViewCellModel.self,
            LogsNoteTableViewCellModel.self,
            LogsPhotoTableViewCellModel.self
        ])

        self.navigationController?.hideHairline()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateScreen()
    }

    @IBAction func subjectSelectButtonTouched(_ sender: UIButton) {
        performSegue(withIdentifier: R.segue.logsViewController.subjectList.identifier, sender: nil)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let info = R.segue.logsViewController.subjectList(segue: segue) {
            info.destination.delegate = self
            info.destination.dataProvider = subjectListDataProvider
            info.destination.direction = .bottom
            slideInTransitionDelegate.direction = .bottom
            slideInTransitionDelegate.sizeOfPresentingViewController = CGSize(width: view.frame.size.width,
                                                                              height: info.destination.contentHeight)
            info.destination.transitioningDelegate = slideInTransitionDelegate
            info.destination.modalPresentationStyle = .custom
        }
    }

    private func updateScreen() {
        // subject must be selected
        let subject: RLMSubject
        if let selection = subjectSelection?.subject {
            subject = selection
        } else {
            guard subjectListDataProvider.numberOfRows > 0 else {
                return
            }
            let indexPath = IndexPath(row: 0, section: 0)
            subject = subjectListDataProvider.model(at: indexPath)
            //subjectSelection?.subject = subject -- Don't ever store it on subjectSelection
        }

        updateSubjectSelectButton(subject: subject)
        dataProvider.fetchLogForm(subject: subject, date: filterDate)
        tableView.reloadData()
    }


    private func updateSubjectSelectButton(subject: RLMSubject) {
        let titleText =  "\(subject.firstName) \(subject.lastName)"
        let titleFont = UIFont.systemFont(ofSize: 16)
        let titleAttributedString = NSMutableAttributedString(string: titleText + "  ", attributes: [NSAttributedString.Key.font: titleFont])
        let chevronFont = UIFont(name: "FontAwesome5Pro-Light", size: 12)
        let chevronAttributedString = NSAttributedString(string: "\u{f078}", attributes: [NSAttributedString.Key.font: chevronFont!])
        titleAttributedString.append(chevronAttributedString)

        subjectSelectButton.setAttributedTitle(titleAttributedString, for: .normal)
    }
}


extension LogsViewController: SubjectListViewControllerDelegate {
    func subjectList(_ controller: SubjectListViewController, didSelect subject: RLMSubject) {
        controller.dismiss(animated: true)
        subjectSelection?.subject = subject
        updateScreen()
    }

    // not used for this view controller
    func subjectListDidSelectAll(_ controller: SubjectListViewController) {
        controller.dismiss(animated: true)
        subjectSelection?.subject = nil
        updateScreen()
    }
}


extension LogsViewController: UITableViewDelegate, UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataProvider.numberOfRows(for: section)
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = dataProvider.model(for: indexPath)
        let cell = tableView.dequeueReusableCell(withAnyModel: model, for: indexPath)
        cell.separatorInset = .zero
        cell.layoutMargins = .zero
        return cell
    }

    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.separatorInset = .zero
        cell.layoutMargins = .zero
    }
}


extension LogsViewController: JTACMonthViewDataSource {
    func configureCalendar(_ calendar: JTACMonthView) -> ConfigurationParameters {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy MM dd"
        let endDate = Date()
        let startDate = Calendar.current.date(byAdding: .day, value: -7, to: endDate)!
        return ConfigurationParameters(startDate: startDate,
                                       endDate: endDate,
                                       numberOfRows: 1,
                                       generateInDates: .forAllMonths,
                                       generateOutDates: .off,
                                       hasStrictBoundaries: false)
    }
}


extension LogsViewController: JTACMonthViewDelegate {
    func calendar(_ calendar: JTACMonthView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTACDayCell {
        let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: "dateCell", for: indexPath) as! DateCell
        self.calendar(calendar, willDisplay: cell, forItemAt: date, cellState: cellState, indexPath: indexPath)
        return cell
    }

    func calendar(_ calendar: JTACMonthView, willDisplay cell: JTACDayCell, forItemAt date: Date, cellState: CellState, indexPath: IndexPath) {
        if let cell = cell as? DateCell {
            cell.configureCell(cellState: cellState)
        }
    }

    func calendar(_ calendar: JTACMonthView, didSelectDate date: Date, cell: JTACDayCell?, cellState: CellState, indexPath: IndexPath) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE MMMM d, yyyy"
        selectedDateLabel.text = dateFormatter.string(from: date)

        if let cell = cell as? DateCell {
            cell.configureCell(cellState: cellState)
        }
        updateScreen()
    }

    func calendar(_ calendar: JTACMonthView, didDeselectDate date: Date, cell: JTACDayCell?, cellState: CellState, indexPath: IndexPath) {
        if let cell = cell as? DateCell {
            cell.configureCell(cellState: cellState)
        }
    }

    func calendar(_ calendar: JTACMonthView, shouldSelectDate date: Date, cell: JTACDayCell?, cellState: CellState, indexPath: IndexPath) -> Bool {
        if date > Date() {
            return false
        } else {
            return true
        }
    }

    func scrollDidEndDecelerating(for calendar: JTACMonthView) {
        let visibleDates = calendarView.visibleDates()
        let startDate = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
        let endLimitDate = Date().next(.saturday, includingTheDate: true)
        let scrollBackDateForEndLimit = Date().previous(.sunday, includingTheDate: true)
        if visibleDates.monthDates.contains(where: {$0.date <= startDate}) {
            calendarView.scrollToDate(startDate)
            return
        }
        if visibleDates.monthDates.contains(where: {$0.date >= endLimitDate}) {
            calendarView.scrollToDate(scrollBackDateForEndLimit)
            return
        }
    }
}
