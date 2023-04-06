import Foundation

@MainActor final class OrganizationDependencyContainer: OrganizationDependencies {
    
    // MARK: Long lived dependencies
    
    var imageRepository: ImageRepository = {
        OrgImageRepository(remoteAPI: OrgImageRemoteAPI())
    }()
    
    // MARK: Factories
    
    func makeOrganizationRepository() -> OrganizationRepository {
        return OrgOrganizationRepository(remoteApi: GitHubOrganizationRemoteAPI())
    }
    
    func makeOrganizationsListController() -> OrganizationsListController {
        return OrgOrganizationsListController(dependencyContainer: self)
    }
}
