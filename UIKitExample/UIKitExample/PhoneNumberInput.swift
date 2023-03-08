import PhoneNumberKit
import UIKit

final class PhoneNumberInput: UIView {
    var onButtonPressed: (PhoneNumberKit) -> Void = { _ in }

    var onTextChanged: (Bool) -> Void = { _ in }

    var phoneNumberE164: String? {
        textField.phoneNumber.map { "+\($0.countryCode)\($0.nationalNumber)" }
    }

    var formattedPhoneNumber: String? {
        textField.phoneNumber.map { "+\($0.countryCode) \($0.numberString)"}
    }

    private let inputStack: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.spacing = 8
        return view
    }()

    private let outerStack: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = 2
        return view
    }()

    private lazy var textField: PhoneNumberTextField = {
        let field = PhoneNumberTextField()
        field.withDefaultPickerUI = true
        field.withPrefix = false
        field.withExamplePlaceholder = true
        field.layer.borderColor = UIColor.placeholder.cgColor
        field.layer.borderWidth = 1
        field.layer.cornerRadius = .cornerRadius
        let view = UIView(frame: .init(x: 0, y: 0, width: 10, height: 10))
        field.leftView = view
        field.leftViewMode = .always
        return field
    }()

    private lazy var countrySelectorButton: UIButton = {
        let button = UIButton(type: .system, primaryAction: .init { [unowned self] _ in
            self.onButtonPressed(self.textField.phoneNumberKit)
        })
        var config = UIButton.Configuration.plain()
        config.baseForegroundColor = .label
        button.configuration = config
        button.layer.borderColor = UIColor.placeholder.cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = .cornerRadius
        return button
    }()

    private let errorLabel: UILabel = {
        let label = UILabel()
        label.textColor = .error
        label.isHidden = true
        return label
    }()

    override var intrinsicContentSize: CGSize {
        outerStack.systemLayoutSizeFitting(.init(width: bounds.width, height: .infinity))
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        inputStack.addArrangedSubview(countrySelectorButton)
        inputStack.addArrangedSubview(textField)

        countrySelectorButton.setContentHuggingPriority(.required, for: .horizontal)

        outerStack.addArrangedSubview(inputStack)
        outerStack.addArrangedSubview(errorLabel)

        outerStack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(outerStack)
        NSLayoutConstraint.activate(
            [
                outerStack.leadingAnchor.constraint(equalTo: leadingAnchor),
                outerStack.trailingAnchor.constraint(equalTo: trailingAnchor),
                outerStack.topAnchor.constraint(equalTo: topAnchor),
                outerStack.bottomAnchor.constraint(equalTo: bottomAnchor),
                inputStack.widthAnchor.constraint(equalTo: outerStack.widthAnchor)
            ] + inputStack.arrangedSubviews.map { view in
                view.heightAnchor.constraint(equalToConstant: 42)
            }
        )

        NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: textField, queue: .main) { [weak self] notification in
            guard let self else { return }
            self.onTextChanged(self.textField.isValidNumber)
        }

        updateButtonTitle()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setErrorText(_ text: String?) {
        errorLabel.text = text
        errorLabel.isHidden = text == nil
        updateBorderColor()
        invalidateIntrinsicContentSize()
    }

    private func updateButtonTitle() {
        guard let countryCode = textField.phoneNumberKit.countryCode(for: textField.currentRegion) else { return }

        let attributedText = NSMutableAttributedString(string: "+ \(countryCode)  ")
        let attachment = NSTextAttachment(image: UIImage(systemName: "chevron.down")!)
        attachment.setImageHeight(height: 10)
        attributedText.append(NSAttributedString(attachment: attachment))
        countrySelectorButton.setAttributedTitle(attributedText, for: .normal)
    }

    private func updateBorderColor() {
        [countrySelectorButton, textField].forEach { view in
            view.layer.borderColor = errorLabel.isHidden ?
            UIColor.placeholder.cgColor :
            UIColor.error.cgColor
        }
    }
}

extension PhoneNumberInput: CountryCodePickerDelegate {
    func countryCodePickerViewControllerDidPickCountry(_ country: CountryCodePickerViewController.Country) {
        textField.countryCodePickerViewControllerDidPickCountry(country)
        updateButtonTitle()
    }
}

private extension NSTextAttachment {
    func setImageHeight(height: CGFloat) {
        guard let image = image else { return }
        let ratio = image.size.width / image.size.height

        bounds = CGRect(x: bounds.origin.x, y: bounds.origin.y, width: ratio * height, height: height)
    }
}
