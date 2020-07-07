import UIKit
import JTAppleCalendar



class LogsViewController: UIViewController {

    @IBOutlet weak var subjectSelectButton: UIButton!
    @IBOutlet weak var calendarView: JTACMonthView!
    @IBOutlet weak var selectedDateLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noItemView: UIView!
    @IBOutlet weak var noItemTitleLabel: UILabel!
    @IBOutlet weak var noItemContentLabel: UILabel!
    @IBOutlet weak var mealPlanButton: UIButton!

    @IBAction func showMenu(_ sender: Any) {
        performSegue(withIdentifier: R.segue.logsViewController.showMenuFromLogs, sender: nil)
    }

    private var reloadPage = true
    private let dataProvider = DefaultLogsDataProvider()
    private lazy var slideInTransitionDelegate = SlideInPresentationManager()
    private let subjectListDataProvider = DefaultSubjectListDataProvider()

    private var filterDate: Date {
        calendarView.selectedDates.first?.startOfDay ?? Date().startOfDay
    }

    private weak var subjectSelection: SubjectSelectionProtocol?

    var selectedLogId: String? = nil {
        didSet {
            if let selectedLogId = selectedLogId {
                (selectedSubjectIdFromFeed,
                 selectedDateFromFeed) = dataProvider.fetchDailyLog(with: selectedLogId)
            }
        }
    }
    private var selectedSubjectIdFromFeed: String? = nil
    private var selectedDateFromFeed: Date? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        subjectSelection = tabBarController as? GuardianTabBarController

        tableView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)

        calendarView.scrollDirection = .horizontal
        calendarView.scrollingMode = .nonStopToCell(withResistance: 0.5)
        calendarView.showsHorizontalScrollIndicator = false

        tableView.register(nibModels: [
            LogsOptionTableViewCellModel.self,
            LogsTimeDetailsTableViewCellModel.self,
            LogsNoteTableViewCellModel.self,
            LogsPhotoTableViewCellModel.self,
            LogsTagsTableViewCellModel.self
        ])

        mealPlanButton.setTitle("utensils", for: .normal)
        self.navigationController?.hideHairline()
        configNoItemView()
    }

    private func configNoItemView() {
        noItemTitleLabel.text = NSLocalizedString("logs_no_item_title", comment: "")
        noItemContentLabel.text = NSLocalizedString("logs_no_item_content", comment: "")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if reloadPage {
            if selectedLogId == nil {
                    selectedSubjectIdFromFeed = nil
                }

                if let selectedDateFromFeed = selectedDateFromFeed {
                    calendarView.scrollToDate(selectedDateFromFeed.previous(.sunday, includingTheDate: true),
                                              animateScroll: false)
                    calendarView.selectDates([selectedDateFromFeed])
                } else {
                    calendarView.scrollToDate(Date().previous(.sunday, includingTheDate: true),
                                              animateScroll: false)
                    calendarView.selectDates([Date()])
                }

                updateScreen()
        }

        reloadPage = true


    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if reloadPage {
            selectedLogId = nil
        }
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
        if let currentSubject = getCurrentSubject() {
            updateSubjectSelectButton(subject: currentSubject)
            updateCalendarView(with: currentSubject)
            dateDidSelect(with: currentSubject)
        }
    }

    private func getCurrentSubject() -> RLMSubject? {
        // subject must be selected
        let subject: RLMSubject?
        if let selectedSubjectIdFromFeed = selectedSubjectIdFromFeed {
            subject = subjectListDataProvider.getSubject(with: selectedSubjectIdFromFeed)
        } else if let selectedSubject = subjectSelection?.subject {
            subject = selectedSubject
        } else {
            guard subjectListDataProvider.numberOfRows > 0 else {
                return nil
            }
            let indexPath = IndexPath(row: 0, section: 0)
            subject = subjectListDataProvider.model(at: indexPath)
            //subjectSelection?.subject = subject -- Don't ever store it on subjectSelection
        }

        return subject
    }

    private func updateCalendarView(with subject: RLMSubject) {
        dataProvider.fetchDailyLogsForChild(with: subject.id)
        calendarView.reloadData()
    }

    private func dateDidSelect(with subject: RLMSubject) {
        selectedDateFromFeed = nil
        dataProvider.selectedDate = filterDate
        noItemView.isHidden = dataProvider.numberOfRows(for: 0) > 0 ? true : false
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
        selectedSubjectIdFromFeed = nil
        controller.dismiss(animated: true)
        subjectSelection?.subject = subject
        updateScreen()
    }

    // not used for this view controller
    func subjectListDidSelectAll(_ controller: SubjectListViewController) {}
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

    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let model = dataProvider.model(for: indexPath)
        if let model = model as? LogsPhotoTableViewCellModel, model.image == nil {
            return 0.0
        } else {
            return UITableView.automaticDimension
        }
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        if let model = dataProvider.model(for: indexPath) as? LogsPhotoTableViewCellModel {
            reloadPage = false
            let storyboard = UIStoryboard(name: "FullScreenPhoto", bundle: .main)
            if let controller = storyboard.instantiateViewController(withIdentifier: "FullSCreenPhotoController") as? FullScreenPhotoController {
                controller.modalPresentationStyle = .fullScreen
                controller.image = model.image
                self.present(controller, animated: true, completion: nil)
            }

        }
    }

}


extension LogsViewController: JTACMonthViewDataSource {

    func configureCalendar(_ calendar: JTACMonthView) -> ConfigurationParameters {
        return ConfigurationParameters(startDate: SubjectsAPIService.startDateOfLogsHistory,
                                       endDate: SubjectsAPIService.endDateOfLogsHistory,
                                       numberOfRows: 1,
                                       generateInDates: .forFirstMonthOnly,
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
            if dataProvider.datesWithData.contains(date.startOfDay),
                date >= SubjectsAPIService.startDateOfLogsHistory.startOfDay {
                cell.hasData = true
            } else {
                cell.hasData = false
            }
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

        if let currentSubject = getCurrentSubject() {
            dateDidSelect(with: currentSubject)
        }
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
        let scrollBackDateForEndLimit = Date().previous(.sunday, includingTheDate: true)
        if visibleDates.monthDates.contains(where: {$0.date <= SubjectsAPIService.startDateOfLogsHistory}) {
            calendarView.scrollToDate(SubjectsAPIService.startDateOfLogsHistory)
            return
        }
        if visibleDates.monthDates.contains(where: {$0.date >= SubjectsAPIService.endDateOfLogsHistory}) {
            calendarView.scrollToDate(scrollBackDateForEndLimit)
            return
        }
    }
}
