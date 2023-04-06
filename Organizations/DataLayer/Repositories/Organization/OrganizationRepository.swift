import Foundation

protocol OrganizationRepository {
    func loadOrganizations() async throws -> OrganizationsListPage
    func loadOrganization(listItem: OrganizationsListItemModel) async throws -> OrganizationModel
}

protocol OrganizationsListPage {
    var organizations: [OrganizationsListItemModel] { get }
    var canLoadNextPage: Bool { get }
    
    func loadNextPage() async throws -> OrganizationsListPage
}
