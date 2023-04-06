import Foundation

final class OrgOrganizationRepository: OrganizationRepository {
    let remoteApi: OrganizationRemoteAPI
    
    init(remoteApi: OrganizationRemoteAPI) {
        self.remoteApi = remoteApi
    }
    
    func loadOrganizations() async throws -> OrganizationsListPage {
        return OrgOrganizationsListPage(remoteApiPage: try await remoteApi.loadOrganizationsList())
    }
    
    func loadOrganization(listItem: OrganizationsListItemModel) async throws -> OrganizationModel {
        return try await remoteApi.loadOrganization(listItem: listItem)
    }
}

struct OrgOrganizationsListPage: OrganizationsListPage {
    private let remoteApiPage: RemoteAPIOrganizationsListPage
    
    fileprivate init(remoteApiPage: RemoteAPIOrganizationsListPage) {
        self.remoteApiPage = remoteApiPage
    }
    
    var organizations: [OrganizationsListItemModel] {
        return remoteApiPage.organizations
    }
    var canLoadNextPage: Bool {
        return remoteApiPage.canLoadNextPage
    }
    
    func loadNextPage() async throws -> OrganizationsListPage {
        return OrgOrganizationsListPage(remoteApiPage: try await remoteApiPage.loadNextPage())
    }
}
