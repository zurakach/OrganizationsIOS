import UIKit

final class LoadingCell: UITableViewCell {
    static let reuseIdentifier = "LoadingCell"
    
    // MARK: Properties
    
    private let indicatorView: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.startAnimating()
        return indicator
    }()
    
    
    // MARK: Methods
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.addSubview(indicatorView)
        self.centerXAnchor.constraint(equalTo: indicatorView.centerXAnchor).isActive = true
        self.centerYAnchor.constraint(equalTo: indicatorView.centerYAnchor).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
