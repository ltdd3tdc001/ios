import UIKit
import SwiftUtils

class CategoryViewController: BaseViewController {

    @IBOutlet private weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
    }

    override func configUI() {
        title = Strings.categoryTitle
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "ic_bt_navigation_back"), style: .plain, target: self, action: #selector(back(_:)))
        navigationItem.leftBarButtonItem?.tintColor = UIColor.white
        tableView.register(CategoryTableViewCell.self)
        tableView.dataSource = self
        tableView.delegate = self
    }
}

// Mark: - UITableViewDataSource
extension CategoryViewController:UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeue(CategoryTableViewCell.self)
        return cell
    }
}

// Mark: - UITableViewDelegate
extension CategoryViewController:UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}
