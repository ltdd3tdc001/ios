import UIKit
import SwiftUtils

class BaseViewController: UIViewController {

    // MARK: - Life cycle
    init() {
        let nibName = String(describing: type(of: self))
        if let _ = Bundle.main.path(forResource: nibName, ofType: "nib") {
            super.init(nibName: nibName, bundle: nil)
        } else {
            super.init(nibName: nil, bundle: nil)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
    }

    deinit {
        notificationDefault.removeObserver(self)
    }

    // MARK: - Functions
    func configUI() {
        automaticallyAdjustsScrollViewInsets = false
        view.backgroundColor = .white
    }

    func alert(error: Error) {
        let alertController = UIAlertController(title: error.localizedDescription, message: nil, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: Strings.ok, style: .cancel)
        alertController.addAction(cancelAction)
        present(alertController, animated: true)
    }

    // MARK: - Function showAlert
    func showAlert(message: String, okHandler: @escaping (UIAlertAction) -> Void) {
        let alertController = UIAlertController(title: Strings.appName, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: Strings.ok, style: .default, handler: okHandler)
        let cancelAction = UIAlertAction(title: Strings.cancel, style: .cancel, handler: nil)
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion:nil)
    }

    // MARK: - Fuction backNavigationController
    func back(_ : UIViewController!) {
         _ = navigationController?.popViewController(animated: true)
    }

    // MARK: - Fuction pushNavigationController
    func push(viewController: UIViewController) {
        navigationController?.pushViewController(viewController, animated: true)
    }

    // MARK: - Status bar style
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
}
