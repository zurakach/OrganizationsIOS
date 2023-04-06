import UIKit

protocol ImageRepository {
    func loadImage(url: URL) async throws -> UIImage
}
