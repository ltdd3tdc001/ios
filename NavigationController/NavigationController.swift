import UIKit

class NavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI() {
        navigationBar.isTranslucent = false
        navigationBar.shadowImage = UIImage()
        navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationBar.makeShadow(color: .black,
                                 shadowOffset: CGSize(width: 0, height: 0.5),
                                 opacity: 0.3)
    }

    func isPushFromViewController<T: UIViewController>(_ aClass: T.Type) -> Bool {
        guard viewControllers.isNotEmpty else { return false }
        let viewController = viewControllers[viewControllers.count - 2]
        return viewController.isMember(of: aClass)
    }
}
