import Foundation
import UIKit

@MainActor final class OrgOrganizationsListController: NSObject, OrganizationsListController {
    
    private let dependencyContainer: OrganizationDependencies
    private let repository: OrganizationRepository
    private var tableView: UITableView?
    private weak var delegate: OrganizationsListControllerDelegate?
    
    private let placeholderImage = UIImage(systemName: "building.2")
    
    private var isFirstPageLoaded = false
    private var loadingTask: Task<Void,Never>?
    
    private var organizations = [OrganizationsListItemModel]()
    private var latestPage: OrganizationsListPage?
    private var loadedImages = [Int: UIImage]()
    private var imageLoadingTasks = [Int: Task<Void, Never>]()
    private var orgDetailsLoadingTasks = [Int: Task<Void, Never>]()
    
    init(dependencyContainer: OrganizationDependencies) {
        self.dependencyContainer = dependencyContainer
        self.repository = dependencyContainer.makeOrganizationRepository()
    }
    
    func attach(tableView: UITableView, delegate: OrganizationsListControllerDelegate) {
        self.delegate = delegate
        self.tableView = tableView
        tableView.register(OrganizationListCell.self, forCellReuseIdentifier: OrganizationListCell.reuseIdentifier)
        tableView.register(LoadingCell.self, forCellReuseIdentifier: LoadingCell.reuseIdentifier)
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func loadOrganizationsIfNeeded() {
        guard !isFirstPageLoaded else { return }
        loadFirstPage()
    }
    
    func stopLoadingOrganizations() {
        loadingTask?.cancel()
    }
    
    private func loadFirstPage() {
        guard loadingTask == nil else { return }
        
        loadingTask = Task { [weak self] in
            defer {
                self?.loadingTask = nil
            }
            do {
                let page = try await self?.repository.loadOrganizations()
                guard let page else { return }
                self?.addPage(page)
            } catch is CancellationError {
                // Do nothing.
            } catch {
                guard let self else { return }
                delegate?.listController(self, didFailToLoadListWithError: error, retryAction: { [weak self] in
                    self?.loadFirstPage()
                })
            }
        }
    }
    
    private func loadNextPageIfNeeded() {
        guard loadingTask == nil else {
            return
        }
        
        guard let latestPage, latestPage.canLoadNextPage else {
            assertionFailure("Requesting to load next page which doesn't exist.")
            return
        }
        
        loadingTask = Task { [weak self] in
            defer {
                self?.loadingTask = nil
            }
            do {
                let nextPage = try await latestPage.loadNextPage()
                self?.addPage(nextPage)
            } catch is CancellationError {
                // Do nothing.
            } catch {
                guard let self else { return }
                delegate?.listController(self, didFailToLoadListWithError: error, retryAction: { [weak self] in
                    self?.loadNextPageIfNeeded()
                })
            }
        }
    }
    
    private func addPage(_ page: OrganizationsListPage) {
        latestPage = page
        organizations.append(contentsOf: page.organizations)
        tableView?.reloadData()
    }
    
    private func shouldShowLoadingCell() -> Bool {
        return loadingTask != nil || (latestPage?.canLoadNextPage ?? false)
    }
    
    private func listItemPresentationModel(for index: Int) -> OrganizationsListItemPresentationModel {
        let isVisitButtonActive = orgDetailsLoadingTasks[index] == nil
        return OrganizationsListItemPresentationModel(image: loadedImages[index] ?? placeholderImage,
                                                      name: organizations[index].name,
                                                      description: organizations[index].description,
                                                      isVisitButtonActive: isVisitButtonActive,
                                                      visitButtonTitle: isVisitButtonActive ? "Visit" : "Opening...")
    }
}

extension OrgOrganizationsListController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let row = indexPath.row
        guard row < organizations.count,
                imageLoadingTasks[row] == nil,
                let imageUrl = organizations[row].imageUrl else { return }
        
        imageLoadingTasks[row] = Task {
            defer {
                imageLoadingTasks[row] = nil
            }
            if let image = try? await dependencyContainer.imageRepository.loadImage(url: imageUrl) {
                loadedImages[row] = image
                tableView.reloadRows(at: [indexPath], with: .none)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard indexPath.row < organizations.count else { return }
        imageLoadingTasks[indexPath.row]?.cancel()
    }
    
}

extension OrgOrganizationsListController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return organizations.count + (self.shouldShowLoadingCell() ? 1 : 0)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == organizations.count {
            loadNextPageIfNeeded()
            return tableView.dequeueReusableCell(withIdentifier: LoadingCell.reuseIdentifier, for: indexPath)
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: OrganizationListCell.reuseIdentifier, for: indexPath) as! OrganizationListCell
        cell.configure(with: listItemPresentationModel(for: indexPath.row))
        cell.delegate = self
        return cell
    }
}

extension OrgOrganizationsListController: OrganizationListCellDelegate {
    
    func organizationListCellDidTapOnVisitButton(_ cell: OrganizationListCell) {
        guard let indexPath = self.tableView?.indexPath(for: cell),
              orgDetailsLoadingTasks[indexPath.row] == nil else { return }
        
        let organization = organizations[indexPath.row]
        orgDetailsLoadingTasks[indexPath.row] = Task {
            defer {
                orgDetailsLoadingTasks[indexPath.row] = nil
                tableView?.reloadRows(at: [indexPath], with: .none)
            }
            tableView?.reloadRows(at: [indexPath], with: .none)
            if let orgDetail = try? await repository.loadOrganization(listItem: organization) {
                delegate?.listController(self, didTapToVisitUrl: orgDetail.htmlUrl)
            }
        }
    }
    
}
