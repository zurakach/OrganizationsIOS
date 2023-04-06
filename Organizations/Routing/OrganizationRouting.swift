import UIKit

@MainActor protocol OrganizationRouting: AnyObject {
    var initialViewController: UIViewController { get }
    
    func displayError(title: String, message: String, retryAction: (()->Void)?)
    
    func openUrl(_ url: URL)
}
