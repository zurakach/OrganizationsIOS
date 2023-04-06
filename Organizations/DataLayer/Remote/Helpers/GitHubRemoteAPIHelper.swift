import Foundation

func parseGitHubLinkHeader(_ linkHeader: String) throws -> [String:String] {
    // Example:
    // <https://api.github.com/organizations?since=3428>; rel="next",
    // <https://api.github.com/organizations{?since}>; rel="first"
    let links = linkHeader.components(separatedBy: ",")
    var result = [String: String]()
    try links.forEach { link in
        let components = link.components(separatedBy:"; ")
        guard components.count == 2 else {
            throw RemoteAPIError.invalidResponse
        }
        var path = components[0]
        // remove '<' and '>'
        path.removeFirst()
        path.removeLast()
        
        // remove 'rel='
        let keyComponents = components[1].components(separatedBy: "=")
        guard keyComponents.count == 2 else {
            throw RemoteAPIError.invalidResponse
        }
        var key = keyComponents[1]
        // remove "
        key.removeFirst()
        key.removeLast()
        
        result[key] = path
    }
    
    return result
}

struct GitHubOrganizationModel: Codable {
    var name: String
    var htmlUrl: URL
    
    enum CodingKeys: String, CodingKey {
        case name = "login"
        case htmlUrl = "html_url"
    }
}

struct GitHubOrganizationsListItemModel: Codable {
    var name: String
    var description: String?
    var url: URL
    var avatarUrl: URL
    
    enum CodingKeys: String, CodingKey {
        case name = "login"
        case description
        case url
        case avatarUrl = "avatar_url"
    }
}
