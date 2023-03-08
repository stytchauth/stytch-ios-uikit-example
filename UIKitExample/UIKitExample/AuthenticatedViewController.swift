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

    override func viewDidLoad() {
        super.viewDidLoad()

        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(logOutButton)
        stackView.addArrangedSubview(poweredByStytch)
        // FIXME: - Add table view
        let spacerView = UIView()
        spacerView.setContentHuggingPriority(.defaultLow, for: .vertical)
        stackView.addArrangedSubview(spacerView)

        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: .horizontalMargin),
            stackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -.horizontalMargin),
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: .verticalMargin),
            stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -.verticalMargin),
        ] + [logOutButton].flatMap {
            [$0.heightAnchor.constraint(equalToConstant: 45), $0.widthAnchor.constraint(equalTo: stackView.widthAnchor)]
        })

        logOutButton.addTarget(self, action: #selector(logOut), for: .touchUpInside)
    }

    func configure(authResponse: AuthenticateResponseType) {

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
