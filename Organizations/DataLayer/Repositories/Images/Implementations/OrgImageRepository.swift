import Foundation
import UIKit

final class OrgImageRepository: ImageRepository {
    private let remoteAPI: ImageRemoteAPI
    
    init(remoteAPI: ImageRemoteAPI) {
        self.remoteAPI = remoteAPI
    }
    
    func loadImage(url: URL) async throws -> UIImage {
        return try await remoteAPI.loadImage(with: url)
        
    }
}
