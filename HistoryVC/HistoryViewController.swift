import UIKit
import SwiftUtils
import RealmSwift

class HistoryViewController: BaseViewController {

    @IBOutlet private weak var tableView: UITableView!

    fileprivate var videos: [Video] = []
    fileprivate var enableLoadMore = false
    fileprivate var nextPageToken = ""
    fileprivate var notificationToken: NotificationToken!

    override func viewDidLoad() {
        super.viewDidLoad()
        do {
            let realm = try Realm()
            self.notificationToken = realm.addNotificationBlock({ (_) in
                self.getAllVideo()
            })
        } catch {}
    }

    deinit {
        notificationToken.stop()
    }

    override func configUI() {
        title = Strings.historyTitle

        navigationItem.rightBarButtonItem = UIBarButtonItem(title: Strings.deleteAll, style: .plain, target: self, action: #selector(deleteAllButtonTouchUpInside(_:)))
        navigationItem.rightBarButtonItem?.tintColor = UIColor.white

        tableView.register(VideoTableViewCell.self)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = Color.black38
        tableView.tableFooterView = UIView()
        getAllVideo()
    }

    @objc private func deleteAllButtonTouchUpInside(_ sender: UIButton) {
        showAlert(message: Strings.confirmDelete) { (_) in
            RealmManager.shared.deleteAllVideo()
            NotificationCenter.default.post(name: NSNotification.Name(Strings.notificationDeleteFavorite), object: nil)
            self.videos.removeAll()
            self.tableView.reloadData()
        }
    }

    // TODO : - load realm
    fileprivate func getAllVideo() {
        self.videos = RealmManager.shared.getAllVideo()
        self.tableView.reloadData()
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let currentOffSet = scrollView.contentOffset.y
        let maxOffSet = scrollView.contentSize.height - scrollView.frame.size.height - 200
        let total = maxOffSet - currentOffSet
        if total <= 0 && enableLoadMore && nextPageToken.isNotEmpty {
            enableLoadMore = false
            getAllVideo()
        }
    }
}

// MARK: - UITableViewDataSource
extension HistoryViewController:UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return videos.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeue(VideoTableViewCell.self)
        cell.config(video: videos[indexPath.row])
        cell.delegate = self
        return cell
    }

    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let video = videos[sourceIndexPath.row]
        videos.remove(at: sourceIndexPath.row)
        videos.insert(video, at: sourceIndexPath.row)
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        videos.remove(at: indexPath.row)
        let indexPaths: [IndexPath] = [indexPath]
        tableView.deleteRows(at: indexPaths, with: .automatic)
    }
}

// MARK: - UITableViewDelegate
extension HistoryViewController:UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detail = DetailViewController()
        detail.video = videos[indexPath.row]
        push(viewController: detail)
    }
}

// MARK: - VideoTableViewCellDelegate
extension HistoryViewController: VideoTableViewCellDelegate {
    func videoTableViewCell(_ cell: VideoTableViewCell, didUpdateFavoriteVideo: Video) {
        showAlert(message: Strings.confirmDeleteFavorite) { (_) in
            NotificationCenter.default.post(name: NSNotification.Name(Strings.notificationDeleteFavorite), object: didUpdateFavoriteVideo)
        }
    }
}
