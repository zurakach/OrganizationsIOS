import Foundation
import UIKit

@MainActor protocol OrganizationsListController {
    func attach(tableView: UITableView, delegate: OrganizationsListControllerDelegate)
    
    func loadOrganizationsIfNeeded()
    func stopLoadingOrganizations()
}

protocol OrganizationsListControllerDelegate: AnyObject {
    func listController(_ controller: OrganizationsListController,
                        didFailToLoadListWithError error: Error,
                        retryAction: (()->Void)?)
    
    func listController(_ controller: OrganizationsListController,
                        didTapToVisitUrl: URL)
}
