import UIKit
import SwiftUtils

let notificationDefault = NotificationCenter.default

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    static var shared: AppDelegate = {
        guard let instance = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("Can not unwrap AppDelegate")
        }
        return instance
    }()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.makeKeyAndVisible()
        window?.rootViewController = createTabbarController()
        UIApplication.shared.statusBarStyle = .lightContent
        return true
    }

    // add create tabbar comtroller

    private func createTabbarController() -> UITabBarController {
        // navi home
        let homeNavi = initNavi(forController: HomeViewController(), image: #imageLiteral(resourceName: "ic_bt_tabbar_home"), title: Strings.homeTitle)

        // navi favorite
        let favoriteNavi = initNavi(forController: FavoriteViewController(), image: #imageLiteral(resourceName: "ic_bt_tabbar_favorite"), title: Strings.favoriteTitle)

        // navi history
        let historyNavi = initNavi(forController: HistoryViewController(), image: #imageLiteral(resourceName: "ic_bt_tabbar_history"), title: Strings.historyTitle)

        // navi search
        let searchNavi = initNavi(forController: SearchViewController(), image: #imageLiteral(resourceName: "ic_bt_tabbar_search"), title: Strings.searchTitle)

        // tabbar
        let tabbarController = UITabBarController()
        tabbarController.viewControllers = [homeNavi, favoriteNavi, historyNavi, searchNavi]
        tabbarController.tabBar.tintColor = UIColor.white
        tabbarController.tabBar.barTintColor = Color.black38

        return tabbarController
    }

    // selection controller

    private func initNavi(forController controller: BaseViewController, image: UIImage, title: String) -> NavigationController {
        let navi = NavigationController(rootViewController: controller)
        navi.tabBarItem.image = image
        navi.title = title
        navi.navigationBar.barTintColor = Color.black38
        navi.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        return navi
    }
}

// - AppDelegate: Events
extension AppDelegate {

    private func showAlert(message: String, buttonTitle: String, handler: ((UIAlertAction) -> Void)?) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: buttonTitle, style: .default, handler: handler))
        if let viewController = window?.rootViewController?.presentedViewController {
            viewController.dismiss(animated: false, completion: {
                self.window?.rootViewController?.present(alert, animated: true, completion: nil)
            })
        } else {
            window?.rootViewController?.present(alert, animated: true, completion: nil)
        }
    }
}
