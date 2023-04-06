import Foundation
import UIKit

protocol ImageRemoteAPI {
    func loadImage(with url: URL) async throws -> UIImage
}
