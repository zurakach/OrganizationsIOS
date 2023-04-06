import Foundation

@MainActor protocol OrganizationDependencies {

    // MARK: Domain
    
    var imageRepository: ImageRepository { get }
    
    func makeOrganizationRepository() -> OrganizationRepository
    
    // MARK: Presentation
    
    func makeOrganizationsListController() -> OrganizationsListController
    
}
