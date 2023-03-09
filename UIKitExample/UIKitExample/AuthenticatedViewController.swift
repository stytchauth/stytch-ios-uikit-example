import StytchCore
import UIKit

final class AuthenticatedViewController: UIViewController {
    private let stackView: UIStackView = {
        let view = UIStackView()
        view.alignment = .center
        view.axis = .vertical
        view.spacing = 24
        return view
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24, weight: .semibold)
        label.textColor = .brand
        label.text = "You're logged in!"
        return label
    }()

    private let collectionView: UICollectionView = {
        var layoutConfig = UICollectionLayoutListConfiguration(appearance: .plain)
        layoutConfig.showsSeparators = false
        let layout = UICollectionViewCompositionalLayout.list(using: layoutConfig)
        return UICollectionView(frame: .zero, collectionViewLayout: layout)
    }()

    private let logOutButton: UIButton = {
        let button = UIButton()
        button.setBackgroundImage(UIColor.brand.image(), for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.setTitle("Log out", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        button.layer.cornerRadius = .cornerRadius
        button.layer.masksToBounds = true
        return button
    }()

    private let poweredByStytch: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "PoweredByStytch")
        return view
    }()

    private lazy var dataSource: UICollectionViewDiffableDataSource<Section, ContentItem> = .init(collectionView: collectionView) { [unowned self] collectionView, indexPath, item in
        collectionView.dequeueConfiguredReusableCell(using: self.registration, for: indexPath, item: item)
    }

    private let registration = UICollectionView.CellRegistration<ContentItemCell, ContentItem> { cell, _, item in
        cell.configure(contentItem: item)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(collectionView)
        stackView.addArrangedSubview(logOutButton)
        stackView.addArrangedSubview(poweredByStytch)
        collectionView.setContentHuggingPriority(.defaultLow, for: .vertical)
        let spacerView = UIView()
        spacerView.setContentHuggingPriority(.defaultLow, for: .vertical)
        stackView.addArrangedSubview(spacerView)

        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: .horizontalMargin),
            stackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -.horizontalMargin),
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: .verticalMargin),
            stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            collectionView.widthAnchor.constraint(equalTo: stackView.widthAnchor),
            collectionView.heightAnchor.constraint(greaterThanOrEqualToConstant: view.bounds.height - 380),
        ] + [logOutButton].flatMap {
            [$0.heightAnchor.constraint(equalToConstant: 45), $0.widthAnchor.constraint(equalTo: stackView.widthAnchor)]
        })

        logOutButton.addTarget(self, action: #selector(logOut), for: .touchUpInside)
    }

    func configure(authResponse: AuthenticateResponseType) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, ContentItem>()
        snapshot.appendSections([.main])
        snapshot.appendItems(.from(authResponse))
        dataSource.apply(snapshot)
    }

    @objc private func logOut() {
        Task {
            do {
                _ = try await StytchClient.sessions.revoke()
            } catch {
                print(error)
            }
            (parent as? HomeViewController)?.logOut()
        }
    }
}

private enum Section { case main }

struct ContentItem: Hashable {
    let icon: Icon
    let title: String
    let content: String
}

extension ContentItem {
    enum Icon: String {
        case person
        case badge
        case email
        case contactMail = "contact_mail"
        case dns
        case subject
        case link
        case howToReg = "how_to_reg"
        case textSMS = "textsms"
        case numbers
    }
}

private extension [ContentItem] {
    static func from(_ authResponse: AuthenticateResponseType) -> Self {
        var items: [ContentItem] = []
        if case let name = authResponse.user.name, [name.firstName, name.middleName, name.lastName].contains(where: { $0?.isEmpty == false }) {
            items.append(
                .init(
                    icon: .person,
                    title: "NAME",
                    content: [name.firstName, name.middleName, name.lastName]
                        .compactMap { $0 }
                        .filter { !$0.isEmpty }
                        .joined(separator: ", ")
                )
            )
        }
        items.append(
            .init(icon: .badge, title: "USER ID", content: authResponse.user.id.rawValue)
        )
        for email in authResponse.user.emails {
            items.append(
                .init(icon: .email, title: "EMAIL", content: email.email)
            )
            items.append(.init(icon: .contactMail, title: "EMAIL ID", content: email.id.rawValue))
        }
        for phone in authResponse.user.phoneNumbers {
            items.append(.init(icon: .numbers, title: "PHONE NUMBER", content: phone.phoneNumber))
            items.append(.init(icon: .textSMS, title: "PHONE ID", content: phone.id.rawValue))
        }
        for provider in authResponse.user.providers {
            items.append(.init(icon: .dns, title: "OAUTH PROVIDER", content: provider.providerType))
            items.append(.init(icon: .dns, title: "PROVIDER SUBJECT", content: provider.providerSubject))
        }
        return items
    }
}
