import UIKit

final class ContentItemCell: UICollectionViewCell {
    private let imageView: UIImageView = .init()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .bold)
        label.textColor = .brand
        return label
    }()

    private let contentLabel: InsetLabel = {
        let view = InsetLabel(frame: .zero)
        view.layoutMargins = .init(top: 8, left: 4, bottom: 8, right: 4)
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.lightBorder.cgColor
        view.layer.cornerRadius = .cornerRadius
        let label = view.label
        label.textColor = .brand
        label.font = .systemFont(ofSize: 16)
        label.numberOfLines = 0
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.addSubview(imageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(contentLabel)

        imageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 24),
            imageView.heightAnchor.constraint(equalToConstant: 24),
            titleLabel.centerYAnchor.constraint(equalTo: imageView.centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 8),
            contentLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            contentLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            contentLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 14),
            contentLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -32),
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(contentItem: ContentItem) {
        imageView.image = UIImage(named: contentItem.icon.rawValue)
        titleLabel.text = contentItem.title
        contentLabel.label.text = contentItem.content
    }
}

private final class InsetLabel: UIView {
    let label: UILabel = .init()

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
            label.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
            label.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor),
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
