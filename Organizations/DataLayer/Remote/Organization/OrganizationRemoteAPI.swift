import Foundation

protocol OrganizationRemoteAPI {
    func loadOrganizationsList() async throws -> RemoteAPIOrganizationsListPage
    func loadOrganization(listItem: OrganizationsListItemModel) async throws -> OrganizationModel
}

protocol RemoteAPIOrganizationsListPage {
    var organizations: [OrganizationsListItemModel] { get }
    var canLoadNextPage: Bool { get }
    
    func loadNextPage() async throws -> RemoteAPIOrganizationsListPage
}
