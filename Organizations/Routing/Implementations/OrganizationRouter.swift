import UIKit

@MainActor final class OrganizationRouter: OrganizationRouting {
    private let dependencyContainer: OrganizationDependencies
    private lazy var navigationController: UINavigationController = {
        var rootVC = OrganizationsListViewController(dependencyContainer: dependencyContainer,
                                                     router: self)
        var navVC = UINavigationController(rootViewController: rootVC)
        return navVC
    }()
    
    init(dependencyContainer: OrganizationDependencies) {
        self.dependencyContainer = dependencyContainer
    }
    
    var initialViewController: UIViewController {
        return navigationController
    }
    
    func displayError(title: String, message: String, retryAction: (()->Void)?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        // TODO: Localization
        if let retryAction {
            alert.addAction(UIAlertAction(title: "Retry", style: .default) { _ in
                retryAction()
            })
        }
        alert.addAction(UIAlertAction(title: "Ok", style: .default))
        navigationController.present(alert, animated: false)
    }
    
    func openUrl(_ url: URL) {
        UIApplication.shared.open(url)
    }
}


