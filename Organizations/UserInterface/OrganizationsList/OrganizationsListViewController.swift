import UIKit

final class OrganizationsListViewController: NiblessViewController {
    
    // MARK: Properties
    private weak var router: OrganizationRouting?
    private var listController: OrganizationsListController
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    // MARK: Methods
    
    init(dependencyContainer: OrganizationDependencies, router: OrganizationRouting) {
        self.router = router
        self.listController = dependencyContainer.makeOrganizationsListController()
        super.init()
    }
    
    override func loadView() {
        self.view = UIView()
        self.view.backgroundColor = UIColor.white
        
        view.addSubview(tableView)
        view.leadingAnchor.constraint(equalTo: tableView.leadingAnchor).isActive = true
        view.trailingAnchor.constraint(equalTo: tableView.trailingAnchor).isActive = true
        view.topAnchor.constraint(equalTo: tableView.topAnchor).isActive = true
        view.bottomAnchor.constraint(equalTo: tableView.bottomAnchor).isActive = true
        listController.attach(tableView: tableView, delegate: self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        listController.loadOrganizationsIfNeeded()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        listController.stopLoadingOrganizations()
    }
}

extension OrganizationsListViewController: OrganizationsListControllerDelegate {
    
    func listController(_ controller: OrganizationsListController, didFailToLoadListWithError error: Error, retryAction: (() -> Void)?) {
        router?.displayError(title: "Error", message: error.localizedDescription, retryAction: retryAction)
    }
    
    func listController(_ controller: OrganizationsListController, didTapToVisitUrl url: URL) {
        router?.openUrl(url)
    }
}
