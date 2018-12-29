import UIKit
import SwiftUtils

class HomeViewController: BaseViewController {

    @IBOutlet private weak var collectionView: UICollectionView!
    fileprivate var videos: [Video] = []
    fileprivate var enableLoadMore = false
    fileprivate var nextPageToken = ""

    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func configUI() {
        super.configUI()
        title = Strings.homeTitle
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "ic_bt_navigation_fire"), style: .plain, target: self, action: nil)
        navigationItem.leftBarButtonItem?.tintColor = UIColor.white
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: Strings.categoryTitle, style: .plain, target: self, action: #selector(gotoCategoryScreen))
        navigationItem.rightBarButtonItem?.tintColor = UIColor.white

        collectionView.register(VideoCollectionViewCell.self)
        collectionView.backgroundColor = Color.black38
        collectionView.delegate = self
        collectionView.dataSource = self
        loadData()
    }

    // MARK: - go category screen
    @objc fileprivate func gotoCategoryScreen() {
        push(viewController: CategoryViewController())
    }

    // MARK: - load API
    fileprivate func loadData() {
        Search.seach(keyword: "", nextPageToken: nextPageToken) { (channel, _) in
            if let channel = channel {
                self.nextPageToken = channel.nextPageToken
                self.videos.append(contentsOf: Array(channel.videos))
                self.enableLoadMore = true
                self.collectionView.reloadData()
            }
        }
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let currentOffSet = scrollView.contentOffset.y
        let maxOffSet = scrollView.contentSize.height - scrollView.frame.size.height - 200
        let total = maxOffSet - currentOffSet
        if total <= 0 && enableLoadMore && nextPageToken.isNotEmpty {
            enableLoadMore = false
            loadData()
        }
    }
}

// MARK: - UICollectionViewDataSource
extension HomeViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return videos.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeue(VideoCollectionViewCell.self, forIndexPath: indexPath)
        cell.config(video: videos[indexPath.row])
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let detail = DetailViewController()
        detail.video = videos[indexPath.row]
        push(viewController: detail)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension HomeViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let collectionViewWith = UIScreen.main.bounds.width
        let itemWith = collectionViewWith - 20
        return CGSize(width: itemWith / 2, height: itemWith / 3)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
    }
}
