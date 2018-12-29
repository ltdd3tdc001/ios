import UIKit
import SwiftUtils
import RealmSwift

class SearchViewController: BaseViewController {

    @IBOutlet fileprivate weak var tableView: UITableView!

    fileprivate var videos: [Video] = []
    fileprivate var keywords: [Keyword] = []
    fileprivate var filtered: [Keyword] = []
    fileprivate var searchBar: UISearchBar?
    fileprivate var isShowingSearchBar = true
    fileprivate var isDisplaySearch = false
    fileprivate var enableLoadMore = false
    fileprivate var nextPageToken = ""

    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func configUI() {
        title = Strings.searchTitle

        createSearchBar()

        tableView.register(VideoTableViewCell.self)
        tableView.register(SuggestionTableViewCell.self)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = Color.black38
        tableView.tableFooterView = UIView()
    }

    private func createSearchBar() {
        searchBar = UISearchBar()
        searchBar?.placeholder = "Enter your search here!"
        searchBar?.delegate = self
        searchBar?.returnKeyType = UIReturnKeyType.done
        searchBar?.becomeFirstResponder()
        navigationItem.titleView = searchBar
    }

    // MARK: - load get all keyword
    fileprivate func getAllKeywords() {
        keywords = RealmManager.shared.getAllKeywords()
    }

    // MARK: - load search API
    fileprivate func searchAPI(keyword: String, isLoadMore: Bool = false) {
        Search.seach(keyword: keyword, nextPageToken: nextPageToken) { (channel, _) in
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
            if let text = searchBar?.text {
                searchAPI(keyword: text, isLoadMore: true)
            }
        }
    }

    fileprivate func searchVideos(keyword: String) {
        searchBar?.text = keyword
        searchBar?.endEditing(true)
        let kw = Keyword()
        kw.keyword = keyword
        RealmManager.shared.addKeyword(kw)
        searchAPI(keyword: keyword)
        isShowingSearchBar = false
        tableView.reloadData()
    }
}

// MARK: - UITableViewDataSource
extension SearchViewController:UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isShowingSearchBar {
            if isDisplaySearch {
                return filtered.count
            } else {
                return keywords.count
            }
        } else {
            return videos.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isShowingSearchBar {
            let cell = tableView.dequeue(SuggestionTableViewCell.self)
            if isDisplaySearch {
                cell.config(keyword: filtered[indexPath.row])
            } else {
                cell.config(keyword: keywords[indexPath.row])
            }
            return cell
        } else {
            let cell = tableView.dequeue(VideoTableViewCell.self)
            cell.config(video: videos[indexPath.row])
            return cell
        }
    }
}

// MARK: - UITableViewDelegate
extension SearchViewController:UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if isShowingSearchBar {
            return 50
        } else {
            return 120
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isShowingSearchBar {
            if isDisplaySearch {
                searchVideos(keyword: filtered[indexPath.row].keyword)
            } else {
                searchVideos(keyword: keywords[indexPath.row].keyword)
            }
        } else {
            let detail = DetailViewController()
            detail.video = videos[indexPath.row]
            push(viewController: detail)
        }
    }
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        let keyword = keywords.remove(at: indexPath.row)
        RealmManager.shared.deleteKeyword(keyword)
        let indexPaths: [IndexPath] = [indexPath]
        tableView.deleteRows(at: indexPaths, with: .automatic)
    }
}

// MARK: - UISearchBarDelegate
extension SearchViewController: UISearchBarDelegate {

    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        isShowingSearchBar = true
        getAllKeywords()
        tableView.reloadData()
        searchBar.showsCancelButton = true
        searchBar.tintColor = UIColor.white
    }

    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        isDisplaySearch = false
        searchBar.showsCancelButton = false
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        isDisplaySearch = false
        searchBar.endEditing(true)
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        isDisplaySearch = false
        searchBar.endEditing(true)
        guard let keyword = searchBar.text else {
            return
        }
        if keyword.isNotEmpty {
            searchVideos(keyword: keyword)
        } else {
            videos.removeAll()
            tableView.reloadData()
        }
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == "" {
            filtered = keywords
        } else {
            filtered = keywords.filter({ (keyword) -> Bool in
                let temp: NSString = (keyword.keyword) as NSString
                let range = temp.range(of: searchText, options: NSString.CompareOptions.caseInsensitive)
                return range.location != NSNotFound
            })
        }
        isDisplaySearch = true
        tableView.reloadData()
    }
}
