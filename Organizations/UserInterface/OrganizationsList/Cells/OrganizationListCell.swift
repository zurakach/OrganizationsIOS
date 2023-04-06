import UIKit

final class OrganizationListCell: UITableViewCell {
    static let reuseIdentifier = "OrganizationListCell"
    
    // MARK: Properties
    private(set) var  organization: OrganizationsListItemPresentationModel?
    weak var delegate: OrganizationListCellDelegate?
    
    // MARK: UI Properties
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = 20
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins.left = 8
        stackView.layoutMargins.right = 8
        stackView.layoutMargins.top = 8
        stackView.layoutMargins.bottom = 8
        return stackView
    }()
    
    private let orgImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor, multiplier: 1).isActive = true
        return imageView
    }()
    
    private let orgDetailsStavkView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        return stackView
    }()
    
    private let orgNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.setContentHuggingPriority(.required, for: .vertical)
        return label
    }()
    
    private let orgDescriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 3
        label.minimumScaleFactor = 0.5
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    private lazy var visitButton: UIButton = {
        let button = UIButton(type: .system)
        button.addTarget(self, action: #selector(visitButtonAction), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: 32).isActive = true
        return button
    }()
    
    // MARK: Methods
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        orgDetailsStavkView.addArrangedSubview(orgNameLabel)
        orgDetailsStavkView.addArrangedSubview(orgDescriptionLabel)
        orgDetailsStavkView.addArrangedSubview(visitButton)
        stackView.addArrangedSubview(orgImageView)
        stackView.addArrangedSubview(orgDetailsStavkView)
        
        self.contentView.addSubview(stackView)
        self.contentView.leadingAnchor.constraint(equalTo: stackView.leadingAnchor).isActive = true
        self.contentView.trailingAnchor.constraint(equalTo: stackView.trailingAnchor).isActive = true
        self.contentView.bottomAnchor.constraint(equalTo: stackView.bottomAnchor).isActive = true
        self.contentView.topAnchor.constraint(equalTo: stackView.topAnchor).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with organization: OrganizationsListItemPresentationModel) {
        self.organization = organization
        orgImageView.image = organization.image
        orgNameLabel.text = organization.name
        orgDescriptionLabel.text = organization.description
        visitButton.isEnabled = organization.isVisitButtonActive
        visitButton.setTitle(organization.visitButtonTitle, for: .normal)
    }
    
    @objc private func visitButtonAction() {
        self.delegate?.organizationListCellDidTapOnVisitButton(self)
    }
}

protocol OrganizationListCellDelegate: AnyObject {
    func organizationListCellDidTapOnVisitButton(_ cell: OrganizationListCell)
}
