//
//  EventCardView.swift
//  Gather
//
//  Created by Renaissance Carr on 6/1/25.
//

import UIKit
import Messages

class EventCardView: UIView {

    private var event: Event?
    private var reactionLabel: UILabel?

    init(event: Event) {
        super.init(frame: .zero)
        transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        alpha = 0
        setupView(with: event)

        UIView.animate(withDuration: 0.4,
                       delay: 0,
                       usingSpringWithDamping: 0.7,
                       initialSpringVelocity: 0.5,
                       options: [],
                       animations: {
            self.alpha = 1
            self.transform = .identity
        }, completion: nil)

        self.layer.transform = CATransform3DMakeScale(1.03, 1.03, 1)
        UIView.animate(withDuration: 0.15, delay: 0.4, options: [.curveEaseOut]) {
            self.layer.transform = CATransform3DIdentity
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView(with event: Event) {
        self.event = event

        let gradient = CAGradientLayer()
        gradient.colors = [
            UIColor(red: 105/255, green: 0, blue: 255/255, alpha: 0.08).cgColor,
            UIColor.white.cgColor
        ]
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 1)
        gradient.frame = bounds
        layer.insertSublayer(gradient, at: 0)

        layer.cornerRadius = 20
        layer.borderWidth = 1
        layer.borderColor = UIColor(red: 105/255, green: 0, blue: 255/255, alpha: 0.2).cgColor
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.15
        layer.shadowOffset = CGSize(width: 0, height: 3)
        layer.shadowRadius = 6

        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 14
        stack.translatesAutoresizingMaskIntoConstraints = false

        let titleLabel = UILabel()
        titleLabel.text = event.title
        titleLabel.font = UIFont.systemFont(ofSize: 30, weight: .black)
        titleLabel.textAlignment = .center
        titleLabel.textColor = UIColor(red: 85/255, green: 0, blue: 200/255, alpha: 1)

        let dateTimeLabel = UILabel()
        dateTimeLabel.text = event.dateTime
        dateTimeLabel.textColor = .darkGray
        dateTimeLabel.font = UIFont.systemFont(ofSize: 16)

        let locationLabel = UILabel()
        locationLabel.text = event.location
        locationLabel.textColor = .gray
        locationLabel.font = UIFont.systemFont(ofSize: 16)

        let detailsLabel = UILabel()
        detailsLabel.text = event.details
        detailsLabel.numberOfLines = 0
        detailsLabel.font = UIFont.systemFont(ofSize: 15)
        detailsLabel.textAlignment = .center

        stack.addArrangedSubview(titleLabel)
        stack.addArrangedSubview(dateTimeLabel)
        stack.addArrangedSubview(locationLabel)

        if let image = event.uiImage {
            let imageView = UIImageView(image: image)
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
            imageView.heightAnchor.constraint(equalToConstant: 180).isActive = true

            imageView.layer.cornerRadius = 12
            imageView.layer.masksToBounds = true
            imageView.layer.borderWidth = 1
            imageView.layer.borderColor = UIColor(red: 105/255, green: 0, blue: 255/255, alpha: 0.2).cgColor

            stack.addArrangedSubview(imageView)
        }

        stack.addArrangedSubview(detailsLabel)

        // --- Reactions UI ---
        let label = UILabel()
        label.text = event.reactions.values.joined(separator: " ")
        label.font = UIFont.systemFont(ofSize: 24)
        label.textAlignment = .center
        self.reactionLabel = label

        let reactionStack = UIStackView(arrangedSubviews: [label])
        reactionStack.axis = .horizontal
        reactionStack.alignment = .center
        reactionStack.distribution = .fill
        reactionStack.spacing = 10

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleReactionTap))
        self.addGestureRecognizer(tapGesture)

        stack.addArrangedSubview(reactionStack)
        // --- End Reactions UI ---
        addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20)
        ])
    }

    @objc private func handleReactionTap() {
        guard var event = self.event else { return }
        let userID = UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString
        event.reactions[userID] = "🙌"
        self.reactionLabel?.text = event.reactions.values.joined(separator: " ")
        self.event = event

        if let controller = parentViewController as? MessagesViewController {
            let message = controller.buildMessage(from: event)
            controller.update(message: message)
        }
    }

    private var parentViewController: UIViewController? {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder?.next
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
        }
        return nil
    }
}
