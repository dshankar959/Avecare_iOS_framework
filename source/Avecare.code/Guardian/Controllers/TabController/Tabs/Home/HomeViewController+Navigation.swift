import UIKit
import CocoaLumberjack



extension HomeViewController {

    @IBAction func didClickSubjectPickerButton(_ sender: UIButton) {
        performSegue(withIdentifier: R.segue.homeViewController.subjectList.identifier, sender: nil)
    }


    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == R.segue.homeViewController.subjectList.identifier,
           let destination = segue.destination as? SubjectListViewController {
            destination.delegate = self
            destination.dataProvider.allSubjectsIncluded = true
            destination.direction = .bottom
            slideInTransitionDelegate.direction = .bottom
            slideInTransitionDelegate.sizeOfPresentingViewController = CGSize(width: view.frame.size.width,
                                                                              height: destination.contentHeight)
            destination.transitioningDelegate = slideInTransitionDelegate
            destination.modalPresentationStyle = .custom
        } else if segue.identifier == R.segue.homeViewController.details.identifier,
            let destination = segue.destination as? FeedDetailsViewController {
            let tuple = sender as? (String, FeedItemType, String)
            destination.feedTitle = tuple?.0
            destination.feedItemType = tuple?.1
            destination.feedItemId = tuple?.2
        }
    }


    func gotoDetailsScreen(with model: HomeTableViewDisclosureCellModel) {
        switch model.feed.feedItemType {
        case .subjectDailyLog:
            gotoLogsScreen(with: model.feed.feedItemId)
        case .message,
             .unitActivity,
             .subjectInjury,
             .subjectReminder:
            performSegue(withIdentifier: R.segue.homeViewController.details, sender: (model.title, model.feed.feedItemType, model.feed.feedItemId))
        case .unitStory:
            gotoStoryDetailScreen(with: model.feed.feedItemId)
        default:
            return
        }
    }


    func gotoLogsScreen(with feedItemId: String) {
        if let navC = tabBarController?.viewControllers?[TabBarItems.logs.index] as? UINavigationController {
            if navC.viewControllers.count > 1 {
                navC.popToRootViewController(animated: false)
            }
            if let logsVC = navC.viewControllers.first as? LogsViewController {
                logsVC.selectedLogId = feedItemId
            }
        }

        // Animated transition
        guard let fromView = tabBarController?.selectedViewController?.view,
            let toView = tabBarController?.viewControllers?[TabBarItems.logs.index].view else { return }

        fromView.superview?.addSubview(toView)
        let screenWidth = UIScreen.main.bounds.width
        toView.center = CGPoint(x: fromView.center.x + screenWidth, y: fromView.center.y)

        view.isUserInteractionEnabled = false

        UIView.animate(withDuration: 0.3, animations: {
            fromView.center = CGPoint(x: fromView.center.x - screenWidth, y: fromView.center.y)
            toView.center = CGPoint(x: toView.center.x - screenWidth, y: toView.center.y)
        }) { finished in
            if finished {
                fromView.removeFromSuperview()
                toView.removeFromSuperview()
                self.tabBarController?.selectedIndex = TabBarItems.logs.index
                self.view.isUserInteractionEnabled = true
            }
        }
    }


    func gotoStoryDetailScreen(with feedItemId: String) {
        if let story = RLMStory.find(withID: feedItemId),
            let detailsVC = UIStoryboard(name: R.storyboard.stories.name, bundle: .main)
                .instantiateViewController(withIdentifier: "StoriesDetailsViewController") as? StoriesDetailsViewController {
            detailsVC.details = StoriesDetails(title: story.title, pdfURL: story.pdfURL(using: DocumentService()), date: story.serverLastUpdated)
            navigationController?.pushViewController(detailsVC, animated: true)
        }
    }

}
