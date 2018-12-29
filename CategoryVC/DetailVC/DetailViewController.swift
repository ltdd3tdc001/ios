import UIKit
import SwiftUtils
import YouTubePlayer_Swift
import RealmSwift

class DetailViewController: BaseViewController {

    @IBOutlet fileprivate var videoPlayer: YouTubePlayerView!
    @IBOutlet private weak var tableView: UITableView!

    fileprivate var videos: [Video] = []
    fileprivate var enableLoadMore = false
    fileprivate var nextPageToken = ""

    var video: Video!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func configUI() {
        title = Strings.detailTitle

        NotificationCenter.default.addObserver(self, selector: #selector(self.deleteFavorite(notification:)), name:NSNotification.Name(Strings.notificationDeleteFavorite), object: nil)
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "ic_bt_navigation_back"), style: .plain, target: self, action: #selector(back(_:)))
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "ic_bt_video_like_while"), style: .done, target: self, action: #selector(changeFavoriteStatus))
        navigationItem.leftBarButtonItem?.tintColor = UIColor.white

        playVideo(video: video)
        tableView.register(HeaderTableView.self)
        tableView.register(VideoTableViewCell.self)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = Color.black34
    }

    @objc fileprivate func changeFavoriteStatus() {
        if RealmManager.shared.isFavorited(video: video) {
            navigationItem.rightBarButtonItem?.tintColor = UIColor.white
            RealmManager.shared.delete(video: video)
        } else {
            navigationItem.rightBarButtonItem?.tintColor = Color.pink244
            RealmManager.shared.addFavorite(video: video)
        }
    }

    // MARK: - play video with id
    fileprivate func playVideo(video: Video) {
        // show video in normal mode (not full screen)
        videoPlayer.playerVars = ["playsinline": 1 as AnyObject]
        videoPlayer.loadVideoID(video.id)
        RealmManager.shared.addHistory(video: video)
        configUIVideoFavorite(video)
        getRelatedVideos()
        tableView.reloadData()
    }

    // MARK: - config UI navigation Favorite
    private func configUIVideoFavorite(_ video: Video) {
        if RealmManager.shared.isFavorited(video: video) {
            navigationItem.rightBarButtonItem?.tintColor = Color.pink244
        } else {
            navigationItem.rightBarButtonItem?.tintColor = UIColor.white
        }
    }

    // MARK: - delete UI favorite notification
    @objc fileprivate func deleteFavorite(notification: NSNotification) {
        navigationItem.rightBarButtonItem?.tintColor = UIColor.white
        guard let videoNotification = notification.object as? Video else { return }
        if video.id == videoNotification.id {
            RealmManager.shared.delete(video: video)
        } else {
            navigationItem.rightBarButtonItem?.tintColor = Color.pink244
            RealmManager.shared.delete(video: videoNotification)
        }
    }

    // MARK: - load API
    fileprivate func getRelatedVideos(isLoadMore: Bool = false) {
        Search.seach(keyword: video.title, nextPageToken: nextPageToken) { (channel, _) in
            if let channel = channel {
                self.nextPageToken = channel.nextPageToken
                if isLoadMore {
                    self.videos.append(contentsOf: Array(channel.videos))
                } else {
                    self.videos = Array(channel.videos)
                }
                self.enableLoadMore = true
                self.tableView.reloadData()
            }
        }
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let currentOffSet = scrollView.contentOffset.y
        let maxOffSet = scrollView.contentSize.height - scrollView.frame.size.height - 200
        let total = maxOffSet - currentOffSet
        if total <= 0 && enableLoadMore && nextPageToken.isNotEmpty {
            enableLoadMore = false
            getRelatedVideos(isLoadMore: true)
        }
    }
}

// MARK: - UITableViewDataSource
extension DetailViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return videos.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeue(VideoTableViewCell.self)
        cell.config(video: videos[indexPath.row])
        return cell
    }
}

// MARK: - UITableViewDelegate
extension DetailViewController:UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 100
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        video = videos[indexPath.row]
        playVideo(video: video)
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = tableView.dequeue(HeaderTableView.self)
        headerView.config(video: video)
        return headerView
    }
}
