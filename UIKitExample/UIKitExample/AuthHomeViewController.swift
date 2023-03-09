import PhoneNumberKit
import StytchCore
import UIKit

final class AuthHomeViewController: UIViewController {
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
        label.text = "Sign up or log in"
        return label
    }()

    private let googleButton: UIButton = makeBorderedButton(image: UIImage(named: "Google"), title: "Continue with Google")

    private let appleButton: UIButton = makeBorderedButton(image: UIImage(systemName: "apple.logo"), title: "Continue with Apple")

    private let separatorView = LabelSeparatorView()

    private let phoneNumberInput = PhoneNumberInput()

    private let continueButton: UIButton = {
        let button = UIButton()
        button.setBackgroundImage(UIColor.disabled.image(), for: .disabled)
        button.setBackgroundImage(UIColor.brand.image(), for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.setTitleColor(.placeholder, for: .disabled)
        button.setTitle("Continue", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        button.isEnabled = false
        return button
    }()

    private let poweredByStytch: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "PoweredByStytch")
        return view
    }()

    private let errorLabel: UILabel = {
        let label = UILabel()
        label.textColor = .error
        label.isHidden = true
        return label
    }()

    private var phoneNumberHasBeenValid = false

    override func viewDidLoad() {
        super.viewDidLoad()

        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(googleButton)
        stackView.addArrangedSubview(appleButton)
        stackView.addArrangedSubview(separatorView)
        stackView.addArrangedSubview(phoneNumberInput)
        stackView.addArrangedSubview(continueButton)
        stackView.addArrangedSubview(poweredByStytch)
        stackView.addArrangedSubview(errorLabel)
        let spacerView = UIView()
        spacerView.setContentHuggingPriority(.defaultLow, for: .vertical)
        stackView.addArrangedSubview(spacerView)

        stackView.setCustomSpacing(12, after: googleButton)
        stackView.setCustomSpacing(12, after: phoneNumberInput)

        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: .horizontalMargin),
            stackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -.horizontalMargin),
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: .verticalMargin),
            stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -.verticalMargin),
            phoneNumberInput.widthAnchor.constraint(equalTo: stackView.widthAnchor),
            separatorView.widthAnchor.constraint(equalTo: stackView.widthAnchor),
        ] + [googleButton, appleButton, continueButton].flatMap {
            [$0.heightAnchor.constraint(equalToConstant: 45), $0.widthAnchor.constraint(equalTo: stackView.widthAnchor)]
        })

        phoneNumberInput.onButtonPressed = { [weak self] phoneNumberKit in
            let countryPickerViewController = CountryCodePickerViewController(phoneNumberKit: phoneNumberKit)
            countryPickerViewController.delegate = self?.phoneNumberInput
            let navigationController = UINavigationController(rootViewController: countryPickerViewController)
            self?.present(navigationController, animated: true)
        }

        phoneNumberInput.onTextChanged = { [weak self] isValid in
            guard let self else { return }

            self.continueButton.isEnabled = isValid

            switch (self.phoneNumberHasBeenValid, isValid) {
            case (_, true):
                self.phoneNumberHasBeenValid = true
                self.phoneNumberInput.setErrorText(nil)
            case (true, false):
                self.phoneNumberInput.setErrorText("Invalid number, please try again.")
            case (false, false):
                break
            }
        }

        separatorView.text = "or"

        googleButton.addTarget(self, action: #selector(didTapGoogle), for: .touchUpInside)
        appleButton.addTarget(self, action: #selector(didTapApple), for: .touchUpInside)
        continueButton.addTarget(self, action: #selector(didTapContinue), for: .touchUpInside)
    }

    @objc private func didTapGoogle() {
        Task {
            do {
                let (token, url) = try await StytchClient.oauth.google.start(
                    parameters: StytchClient.OAuth.ThirdParty.WebAuthSessionStartParameters(
                        loginRedirectUrl: URL(string: "uikit-example://login")!,
                        signupRedirectUrl: URL(string: "uikit-example://signup")!
                    )
                )
                let result = try await StytchClient.oauth.authenticate(parameters: .init(token: token))
                print(url.pathComponents.last == "login" ? "Welcome back!" : "Welcome")
                authenticate(response: result)
            } catch {
                print(error)
            }
        }
    }

    @objc private func didTapApple() {
        Task {
            do {
                let result = try await StytchClient.oauth.apple.start(parameters: .init())
                authenticate(response: result)
            } catch {
                print(error)
            }
        }
    }

    @objc private func didTapContinue() {
        Task {
            do {
                guard let phoneNumber = phoneNumberInput.phoneNumberE164 else { return }

                let codeExpiry = Date().addingTimeInterval(120)

                let result = try await StytchClient.otps.loginOrCreate(parameters: .init(deliveryMethod: .sms(phoneNumber: phoneNumber), expiration: 2))

                let controller = OTPCodeViewController()
                controller.configure(
                    phoneNumberE164: phoneNumber,
                    formattedPhoneNumber: phoneNumberInput.formattedPhoneNumber!,
                    methodId: result.methodId,
                    codeExpiry: codeExpiry
                ) { [weak self, weak controller] response in
                    controller?.dismiss(animated: true)
                    self?.authenticate(response: response)
                }
                self.present(controller, animated: true)
            } catch {
                print(error)
            }
        }
    }

    private func authenticate(response: AuthenticateResponseType) {
        (parent as? HomeViewController)?.logIn(response: response)
    }

    private static func makeBorderedButton(image: UIImage?, title: String) -> UIButton {
        let button = UIButton()
        var config = UIButton.Configuration.plain()
        config.baseForegroundColor = .label
        config.image = image
        config.imagePadding = 8
        var text = AttributedString(title)
        text.font = .systemFont(ofSize: 18, weight: .semibold)
        config.attributedTitle = text
        button.configuration = config
        button.layer.borderColor = UIColor.brand.cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = .cornerRadius
        return button
    }
}

