import Foundation

final class GitHubOrganizationRemoteAPI: OrganizationRemoteAPI {
    
    private let domain = "https://api.github.com"
    
    func loadOrganizationsList() async throws -> RemoteAPIOrganizationsListPage {
        let url =  URL(string: "\(domain)/organizations")!
        return try await loadRemoteAPIOrganizationsListPage(from: url)
    }
    
    func loadOrganization(listItem: OrganizationsListItemModel) async throws -> OrganizationModel {
        let url = URL(string: "\(domain)/orgs/\(listItem.name)")!
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let response = response as? HTTPURLResponse,
              response.statusCode == 200 else {
            throw RemoteAPIError.invalidResponse
        }
        
        guard let organization = try? JSONDecoder().decode(GitHubOrganizationModel.self, from: data) else {
            throw RemoteAPIError.invalidResponse
        }
        return OrganizationModel(name: organization.name, htmlUrl: organization.htmlUrl)
    }
}

struct GitHubRemoteAPIOrganizationsListPage: RemoteAPIOrganizationsListPage {
    
    // MARK: Properties
    var organizations: [OrganizationsListItemModel]
    var canLoadNextPage: Bool {
        return nextPageUrl != nil
    }
    var nextPageUrl: URL?
    
    // MARK: Methods
    func loadNextPage() async throws -> RemoteAPIOrganizationsListPage {
        guard let nextPageUrl else {
            assertionFailure("Requesting to load a next page of the last page.")
            return GitHubRemoteAPIOrganizationsListPage(organizations: [])
        }
        return try await loadRemoteAPIOrganizationsListPage(from: nextPageUrl)
    }
}

private func loadRemoteAPIOrganizationsListPage(from url: URL) async throws -> GitHubRemoteAPIOrganizationsListPage {
    let (data, response) = try await URLSession.shared.data(from: url)
    
    guard let response = response as? HTTPURLResponse,
          response.statusCode == 200 else {
        throw RemoteAPIError.invalidResponse
    }
    
    var nextPageUrl: URL?
    if let linkHeader = response.value(forHTTPHeaderField: "Link") {
        let links = try parseGitHubLinkHeader(linkHeader)
        if let next = links["next"] {
            nextPageUrl = URL(string: next)
        }
    }
    
    guard let githubOrganizations = try? JSONDecoder().decode([GitHubOrganizationsListItemModel].self, from: data) else {
        throw RemoteAPIError.invalidResponse
    }
    return GitHubRemoteAPIOrganizationsListPage(organizations:githubOrganizations.map({
        OrganizationsListItemModel(name: $0.name,
                                   description: $0.description,
                                   imageUrl: $0.avatarUrl)}),
                                                nextPageUrl: nextPageUrl)
}
