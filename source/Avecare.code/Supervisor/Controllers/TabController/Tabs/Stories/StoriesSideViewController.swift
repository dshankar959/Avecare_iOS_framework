import UIKit
import CocoaLumberjack
import PDFKit
import MobileCoreServices
import RealmSwift



class StoriesSideViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    var currentThumbview: PDFThumbView?

    lazy var dataProvider: StoriesDataProviderIO = {
        let provider = StoriesDataProvider()
        provider.delegate = self
        return provider
    }()

    // DB update notifications
    private var dbNotificationsToken: NotificationToken? = nil


    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(nibModels: [
            StoriesTableViewCellModel.self
        ])

        dataProvider.fetchAll()

        // select first row by default
        if dataProvider.numberOfRows > 0 {
            dataProvider.setSelected(true, at: IndexPath(row: 0, section: 0))
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        dbNotifications(true)
        if let detailsViewController = customSplitController?.rightViewController as? DetailsFormViewController {
            detailsViewController.updateSyncButton()
        }
    }


    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        dbNotifications(false)
    }


    public func pickDocuments() {
        let pickerController = UIDocumentPickerViewController(documentTypes: [kUTTypePDF as String, kUTTypeImage as String], in: .import)
        pickerController.delegate = self
        pickerController.allowsMultipleSelection = false

        if #available(iOS 13.0, *) {
            pickerController.shouldShowFileExtensions = true
        }

        pickerController.modalPresentationStyle = .fullScreen
        self.present(pickerController, animated: true)
    }

    deinit {
    }

}


extension StoriesSideViewController: UIDocumentPickerDelegate {

    func generatePdfThumbnail(of thumbnailSize: CGSize, for documentUrl: URL, atPage pageIndex: Int) -> UIImage? {
        let pdfDocument = PDFDocument(url: documentUrl)
        let pdfDocumentPage = pdfDocument?.page(at: pageIndex)
        return pdfDocumentPage?.thumbnail(of: thumbnailSize, for: PDFDisplayBox.trimBox)
    }

    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        if let currentThumbview = currentThumbview {
            dataProvider.didPickDocumentsAt(urls: urls, view: currentThumbview)
        }
    }

    public func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {}

}


extension StoriesSideViewController: UITableViewDelegate, UITableViewDataSource {

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataProvider.numberOfRows
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = dataProvider.model(for: indexPath)
        return tableView.dequeueReusableCell(withModel: model, for: indexPath)
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dataProvider.setSelected(true, at: indexPath)
    }

    public func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        // Not showing delete option if there is only one story or the story is already published
        if self.dataProvider.numberOfRows < 2 || self.dataProvider.isRowStoryPublished(at: indexPath) {
            return []
        }

        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
            if self.dataProvider.numberOfRows > 1 {
                if indexPath.row > 0 {
                    self.dataProvider.setSelected(true, at: IndexPath(row: indexPath.row-1, section: indexPath.section))
                } else {
                    self.dataProvider.setSelected(true, at: IndexPath(row: 1, section: indexPath.section))
                }
            }
            // delete story at indexPath and update UI
            self.dataProvider.removeStoryAt(at: indexPath)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }

        delete.backgroundColor = UIColor.red
        return [delete]

    }

}


extension StoriesSideViewController: StoriesDataProviderDelegate, IndicatorProtocol {

    func showError(title: String, message: String) {
        let error = AppError(title: title, userInfo: message, code: "", type: "")
        self.showErrorAlert(error)
    }

    func gotToPDFDetail(fileUrl: URL) {
        performSegue(withIdentifier: "PDFOpenView", sender: fileUrl)
    }

    func didTapPDF(story: RLMStory, view: PDFThumbView) {
        self.currentThumbview = view
        pickDocuments()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destVC = segue.destination as? PDFVIewController, let url = sender as? URL {
            destVC.url = url
        }
    }

    func didUpdateModel(at indexPath: IndexPath, details: Bool) {
        let model = dataProvider.model(for: indexPath)

        if let cell = tableView.cellForRow(at: indexPath) {
            model.setup(cell: cell)
        }

        if details, model.isSelected, let detailsViewController = customSplitController?.rightViewController as? DetailsFormViewController {
            detailsViewController.updateSyncButton()
            let form = dataProvider.form(at: indexPath)
            detailsViewController.detailsView.setFormViews(form.viewModels)
            detailsViewController.navigationHeaderView.items = dataProvider.navigationItems(at: indexPath)
        }
    }

    func didCreateNewStory() {
        let indexPath = IndexPath(row: 0, section: 0)
        tableView.insertRows(at: [indexPath], with: .top)
        dataProvider.setSelected(true, at: indexPath)
    }

    func moveStory(at fromIndexPath: IndexPath, to toIndexPath: IndexPath) {
        if let indexes = tableView.indexPathsForVisibleRows {
            if indexes.contains(fromIndexPath) {
                tableView.moveRow(at: fromIndexPath, to: toIndexPath)
            } else if indexes.contains(toIndexPath) {
                tableView.reloadRows(at: indexes, with: .automatic)
            }
        }
    }

}


extension StoriesSideViewController {

    func dbNotifications(_ enable: Bool) {
        if enable {
            if dbNotificationsToken == nil {
//                DDLogDebug("[RLMStory] dbNotifications: ON 🔔")
                dbNotificationsToken = RLMStory().setupNotificationToken(for: self) { [weak self] in
                    // Update data from db again
                    self?.dataProvider.fetchAll()
                    self?.tableView.reloadData()
                }
            }
        } else {  // disable
//            DDLogDebug("[RLMStory] dbNotifications: OFF 🔕")
            dbNotificationsToken?.invalidate()
            dbNotificationsToken = nil
        }
    }

}