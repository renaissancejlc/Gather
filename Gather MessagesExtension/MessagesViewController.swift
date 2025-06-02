
//
//  MessagesViewController.swift
//  Gather MessagesExtension
//
//  Created by Renaissance Carr on 6/1/25.
//

import UIKit
import Messages
import PhotosUI

class MessagesViewController: MSMessagesAppViewController, PHPickerViewControllerDelegate {
    

    // Persistent unique user ID for this device/user
    var localUserID: String {
        if let id = UserDefaults.standard.string(forKey: "gatherUserID") {
            return id
        } else {
            let id = UUID().uuidString
            UserDefaults.standard.set(id, forKey: "gatherUserID")
            return id
        }
    }
    
    // Store selected image and image picker button for events
    var selectedImage: UIImage?
    let imageButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        print("✅ MessagesViewController loaded")
    }
    
    // MARK: - Conversation Handling
    
    override func willBecomeActive(with conversation: MSConversation) {
        if presentationStyle != .expanded {
            print("🔁 Requesting expanded style")
            requestPresentationStyle(.expanded)
        }
        super.willBecomeActive(with: conversation)

        if let selectedMessage = conversation.selectedMessage {
            print("📩 Handling selected message from willBecomeActive")
            didReceive(selectedMessage, conversation: conversation)
        } else {
            showPollCreationView()
        }
    }
    
    func showPollCreationView() {
        view.subviews.forEach { $0.removeFromSuperview() }

        let features = [
            ("Polls", "checkmark.circle"),
            ("Events", "calendar"),
            ("Micro RSVP", "person.crop.circle.badge.checkmark"),
            ("Scheduler", "clock"),
            ("Checklist", "list.bullet"),
            ("Notes", "note.text"),
            ("Bringing", "shippingbox"),
            ("Info", "gearshape")
        ]

        let grid = UIStackView()
        grid.axis = .vertical
        grid.spacing = 24
        grid.translatesAutoresizingMaskIntoConstraints = false
        grid.layoutMargins = UIEdgeInsets(top: 60, left: 0, bottom: 0, right: 0)
        grid.isLayoutMarginsRelativeArrangement = true

        for row in stride(from: 0, to: features.count, by: 3) {
            let hStack = UIStackView()
            hStack.axis = .horizontal
            hStack.distribution = .fillEqually
            hStack.spacing = 16

            for i in row..<min(row + 3, features.count) {
                let (title, iconName) = features[i]
                let button = UIButton(type: .system)
                button.setTitleColor(.white, for: .normal)
                button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
                let hueOffset = CGFloat(i) * 0.03
                let baseColor = UIColor(displayP3Red: 138/255, green: 43/255, blue: 226/255, alpha: 1) // Electric Violet base
                let adjustedColor = baseColor.withHueOffset(hueOffset)
                button.backgroundColor = adjustedColor
                button.layer.cornerRadius = 12
                NSLayoutConstraint.activate([
                    button.widthAnchor.constraint(equalToConstant: 80),
                    button.heightAnchor.constraint(equalToConstant: 80)
                ])

                let icon = UIImage(systemName: iconName)
                button.setImage(icon, for: .normal)
                button.tintColor = .white
                button.imageView?.contentMode = .center
                button.contentHorizontalAlignment = .center
                button.contentVerticalAlignment = .center
                button.imageEdgeInsets = .zero

                if title == "Polls" {
                    button.addTarget(self, action: #selector(showLegacyPollCreator), for: .touchUpInside)
                }
                else if title == "Events" {
                    button.addTarget(self, action: #selector(showEventCreationView), for: .touchUpInside)
                }
                else if title == "Scheduler" {
                    button.addTarget(self, action: #selector(showSchedulerViewController), for: .touchUpInside)
                }

                let label = UILabel()
                label.text = title
                label.textAlignment = .center
                label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
                label.textColor = .white

                let vStack = UIStackView(arrangedSubviews: [button, label])
                vStack.axis = .vertical
                vStack.alignment = .center
                vStack.spacing = 6

                hStack.addArrangedSubview(vStack)
            }

            grid.addArrangedSubview(hStack)
        }

        let titleLabel = UILabel()
        titleLabel.text = "Gather"
        titleLabel.font = UIFont.systemFont(ofSize: 28, weight: .heavy)
        titleLabel.textColor = UIColor(displayP3Red: 138/255, green: 43/255, blue: 226/255, alpha: 1)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)

        view.addSubview(grid)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 40),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            grid.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 30),
            grid.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            grid.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9)
        ])
        grid.layoutIfNeeded()
    }
    
    @objc func showSchedulerViewController() {
        let schedulerVC = SchedulerViewController()
        schedulerVC.modalPresentationStyle = .formSheet
        present(schedulerVC, animated: true, completion: nil)
    }

    @objc func sendPollButtonTapped(_ sender: UIButton) {
        guard let stack = view.viewWithTag(999) as? UIStackView else { return }
        guard let questionField = stack.arrangedSubviews.first as? UITextField,
              let question = questionField.text, !question.isEmpty else { return }

        let optionFields = stack.arrangedSubviews.compactMap { $0 as? UITextField }.dropFirst()
        let options = optionFields.compactMap { $0.text }.filter { !$0.isEmpty }.prefix(5)
            .map { PollOption(text: $0, votes: 0) }

        guard !options.isEmpty else { return }
        
        print("📤 Creating poll with question: \(question), options: \(options.map { $0.text })")

        let poll = Poll(question: question, options: options, isMultiSelect: false)

        if let conversation = activeConversation {
            print("📨 About to call sendPoll")
            sendPoll(poll, in: conversation)
        }
    }
    
    override func didResignActive(with conversation: MSConversation) {
        // Called when the extension is about to move from the active to inactive state.
        // This will happen when the user dismisses the extension, changes to a different
        // conversation or quits Messages.
        
        // Use this method to release shared resources, save user data, invalidate timers,
        // and store enough state information to restore your extension to its current state
        // in case it is terminated later.
    }
   
    override func didReceive(_ message: MSMessage, conversation: MSConversation) {
        guard let url = message.url,
              let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let queryItems = components.queryItems,
              let dataItem = queryItems.first(where: { $0.name == "data" }),
              let encodedData = dataItem.value,
              let decodedData = Data(base64Encoded: encodedData) else {
            return
        }

        let decoder = JSONDecoder()

        if let poll = try? decoder.decode(Poll.self, from: decodedData) {
            // Show PollCardView
            let alreadyVoted = poll.hasVoted(userID: localUserID)
            let cardView = PollCardView(poll: poll, isInteractive: !alreadyVoted, showResults: alreadyVoted) { [weak self] selectedIndex in
                self?.submitVote(optionIndex: selectedIndex, poll: poll)
            }
            showCardView(cardView)
        } else if let event = try? decoder.decode(Event.self, from: decodedData) {
            // Show EventCardView
            let cardView = EventCardView(event: event)
            showCardView(cardView)
        } else {
            print("⚠️ Unable to decode data as Poll or Event")
        }
    }

    func showCardView(_ cardView: UIView) {
        view.subviews.forEach { $0.removeFromSuperview() }
        cardView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(cardView)
        NSLayoutConstraint.activate([
            cardView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            cardView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            cardView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.85)
        ])
        view.setNeedsLayout()
        view.layoutIfNeeded()
    }
    
    override func didStartSending(_ message: MSMessage, conversation: MSConversation) {
        // Called when the user taps the send button.
    }
    
    override func didCancelSending(_ message: MSMessage, conversation: MSConversation) {
        // Called when the user deletes the message without sending it.
    
        // Use this to clean up state related to the deleted message.
    }
    
    override func willTransition(to presentationStyle: MSMessagesAppPresentationStyle) {
        // Called before the extension transitions to a new presentation style.
    
        // Use this method to prepare for the change in presentation style.
    }
    
    override func didTransition(to presentationStyle: MSMessagesAppPresentationStyle) {
        // Called after the extension transitions to a new presentation style.
    
        // Use this method to finalize any behaviors associated with the change in presentation style.
    }
    func sendPoll(_ poll: Poll, in conversation: MSConversation, using originalMessage: MSMessage? = nil) {
        print("📦 Encoding poll: \(poll.question)")
        if let url = encodePollToURL(poll) {
            print("📦 Encoded URL: \(url.absoluteString)")
            print("🛰 Sending URL: \(url.absoluteString)")

            let layout = MSMessageTemplateLayout()
            layout.caption = "Poll: \(poll.question)"
            layout.subcaption = "Tap to vote or view results"
            layout.trailingCaption = "Gather"
            layout.image = UIImage(named: "poll_icon") // Optional icon
            layout.imageTitle = "Gather Poll"
            layout.imageSubtitle = "Created via Gather"

            if let bubbleImage = UIImage(named: "violet_bubble_background") {
                layout.image = bubbleImage
            }

            // Ensure session, layout, and url are set before insert
            let message = MSMessage(session: originalMessage?.session ?? conversation.selectedMessage?.session ?? MSSession())
            message.summaryText = "Poll: \(poll.question)"
            message.layout = layout
            message.url = url

            conversation.insert(message) { error in
                if let error = error {
                    print("❌ Error sending message: \(error.localizedDescription)")
                } else {
                    print("✅ Poll message sent!")
                    print("📬 Inserted message with URL: \(String(describing: message.url))")
                }
            }
        } else {
            print("❌ Failed to encode poll URL")
        }
    }
    
    func encodePollToURL(_ poll: Poll) -> URL? {
        guard let data = try? JSONEncoder().encode(poll) else { return nil }
        print("🧬 Encoded poll data to base64")
        let base64 = data.base64EncodedString()

        var components = URLComponents()
        components.scheme = "https"
        components.host = "gather.poll"
        components.queryItems = [
            URLQueryItem(name: "data", value: base64)
        ]
        return components.url
    }
    
    func showPollCard(_ poll: Poll, allowVoting: Bool = true) {
        view.subviews.forEach { $0.removeFromSuperview() }
        let showResults = !allowVoting
        let card = PollCardView(poll: poll, isInteractive: allowVoting, showResults: showResults) { [weak self] selectedIndex in
            self?.submitVote(optionIndex: selectedIndex, poll: poll)
        }
        card.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(card)

        NSLayoutConstraint.activate([
            card.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            card.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            card.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.85)
        ])
        view.setNeedsLayout()
        view.layoutIfNeeded()
    }

    func submitVote(optionIndex: Int, poll: Poll) {
        // Haptic feedback before sending poll
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.prepare()
        generator.impactOccurred()

        var updatedPoll = poll
        updatedPoll.vote(from: localUserID, at: optionIndex)
        print("🗳️ Submitted vote for option: \(poll.options[optionIndex].text) by user \(localUserID)")
        print("📊 Voted user IDs before sending: \(updatedPoll.votedUserIDs)")

        guard let conversation = activeConversation else { return }
        sendPoll(updatedPoll, in: conversation, using: conversation.selectedMessage)
        showPollCard(updatedPoll, allowVoting: false)
    }

    @objc func showLegacyPollCreator() {
        let alert = UIAlertController(title: "Polls", message: "Launching poll creator...", preferredStyle: .alert)
        present(alert, animated: true) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                alert.dismiss(animated: true)
                self.showOldPollCreationForm()
            }
        }
    }

    func showOldPollCreationForm() {
        view.subviews.forEach { $0.removeFromSuperview() }

        // Title label above the poll creation form
        let titleLabel = UILabel()
        titleLabel.text = "Gather Polls"
        titleLabel.font = UIFont.systemFont(ofSize: 24, weight: .heavy)
        titleLabel.textColor = UIColor(displayP3Red: 138/255, green: 43/255, blue: 226/255, alpha: 1)
        titleLabel.textAlignment = .center
        titleLabel.setContentHuggingPriority(.required, for: .vertical)

        // Back button above the poll creation form
        let backButton = UIButton(type: .system)
        backButton.setTitle("← Back", for: .normal)
        backButton.setTitleColor(.systemBlue, for: .normal)
        backButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        backButton.contentHorizontalAlignment = .left
        backButton.addTarget(self, action: #selector(showPollCreationViewButtonTapped), for: .touchUpInside)

        let questionField = UITextField()
        questionField.placeholder = "Enter your poll question here..."
        questionField.borderStyle = .roundedRect

        var optionFields: [UITextField] = []
        for i in 0..<5 {
            let option = UITextField()
            option.placeholder = "Option \(i + 1)"
            option.borderStyle = .roundedRect
            optionFields.append(option)
        }

        let sendButton = UIButton(type: .system)
        sendButton.setTitle("Send Poll", for: .normal)
        sendButton.setTitleColor(.white, for: .normal)
        sendButton.backgroundColor = UIColor(displayP3Red: 138/255, green: 43/255, blue: 226/255, alpha: 1)
        sendButton.layer.cornerRadius = 10
        sendButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        sendButton.contentEdgeInsets = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
        sendButton.addTarget(self, action: #selector(sendPollButtonTapped(_:)), for: .touchUpInside)

        let stack = UIStackView(arrangedSubviews: [titleLabel, backButton, questionField] + optionFields + [sendButton])
        stack.axis = .vertical
        stack.spacing = 10
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.tag = 999

        view.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stack.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.85)
        ])
    }

    @objc func showPollCreationViewButtonTapped() {
        showPollCreationView()
    }

    @objc func showEventCreationView() {
        view.subviews.forEach { $0.removeFromSuperview() }
        selectedImage = nil
        imageButton.setTitle("Choose Image", for: .normal)

        // Title label
        let titleLabel = UILabel()
        titleLabel.text = "Gather Events"
        titleLabel.font = UIFont.systemFont(ofSize: 24, weight: .heavy)
        titleLabel.textColor = UIColor(displayP3Red: 138/255, green: 43/255, blue: 226/255, alpha: 1)
        titleLabel.textAlignment = .center
        titleLabel.setContentHuggingPriority(.required, for: .vertical)

        // Back button
        let backButton = UIButton(type: .system)
        backButton.setTitle("← Back", for: .normal)
        backButton.setTitleColor(.systemBlue, for: .normal)
        backButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        backButton.contentHorizontalAlignment = .left
        backButton.addTarget(self, action: #selector(showPollCreationViewButtonTapped), for: .touchUpInside)

        // Form fields
        let titleField = UITextField()
        titleField.placeholder = "Event Title"
        titleField.borderStyle = .roundedRect

        let dateTimeField = UITextField()
        dateTimeField.placeholder = "Date & Time"
        dateTimeField.borderStyle = .roundedRect

        let locationField = UITextField()
        locationField.placeholder = "Location"
        locationField.borderStyle = .roundedRect

        let detailsField = UITextField()
        detailsField.placeholder = "Additional Details"
        detailsField.borderStyle = .roundedRect

        // Image picker button
        imageButton.setTitle("Choose Image", for: .normal)
        imageButton.setTitleColor(.systemBlue, for: .normal)
        imageButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        imageButton.layer.cornerRadius = 8
        imageButton.backgroundColor = UIColor.systemGray6
        imageButton.contentEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        imageButton.addTarget(self, action: #selector(pickImageTapped), for: .touchUpInside)

        let createButton = UIButton(type: .system)
        createButton.setTitle("Create Event", for: .normal)
        createButton.setTitleColor(.white, for: .normal)
        createButton.backgroundColor = UIColor(displayP3Red: 138/255, green: 43/255, blue: 226/255, alpha: 1)
        createButton.layer.cornerRadius = 10
        createButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        createButton.contentEdgeInsets = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
        createButton.addTarget(self, action: #selector(eventSubmitTapped), for: .touchUpInside)

        let stack = UIStackView(arrangedSubviews: [titleLabel, backButton, titleField, dateTimeField, locationField, detailsField, imageButton, createButton])
        stack.axis = .vertical
        stack.spacing = 10
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stack.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.85)
        ])
    }

    @objc func pickImageTapped() {
        var config = PHPickerConfiguration()
        config.selectionLimit = 1
        config.filter = .images

        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        present(picker, animated: true)
    }

    @objc func eventSubmitTapped() {
        // Find the stack view containing the form fields
        guard let stack = view.subviews.first(where: { $0 is UIStackView }) as? UIStackView else { return }
        let fields = stack.arrangedSubviews.compactMap { $0 as? UITextField }
        guard fields.count >= 4 else { return }
        let titleField = fields[0]
        let dateTimeField = fields[1]
        let locationField = fields[2]
        let detailsField = fields[3]

        guard let title = titleField.text, !title.isEmpty,
              let dateTime = dateTimeField.text, !dateTime.isEmpty,
              let location = locationField.text, !location.isEmpty,
              let details = detailsField.text else {
            return
        }

        // Prepare image data (Data?) for Event struct
        var imageData: Data? = nil
        if let selected = selectedImage {
            imageData = selected.jpegData(compressionQuality: 0.8)
        }

        // Compose Event struct as per required definition
        let event = Event(
            id: UUID().uuidString,
            title: title,
            location: location,
            dateTime: dateTime,
            details: details,
            imageData: imageData,
            reactions: [:]
        )

        let encoder = JSONEncoder()
        guard let encoded = try? encoder.encode(event) else { return }
        let base64 = encoded.base64EncodedString()

        var components = URLComponents()
        components.scheme = "https"
        components.host = "gather.event"
        components.queryItems = [
            URLQueryItem(name: "data", value: base64)
        ]

        guard let url = components.url else { return }

        // Build MSMessageTemplateLayout using property assignments as per new pattern
        let layout = MSMessageTemplateLayout()
        layout.caption = event.title
        layout.subcaption = event.location
        layout.trailingSubcaption = event.dateTime
        if let data = event.imageData {
            let image = UIImage(data: data)
            layout.image = image
        }
        // Example: reactions string (if you have reactions data, otherwise leave as blank or static)
        layout.trailingCaption = "Reactions"

        let message = MSMessage()
        message.layout = layout
        message.url = url

        activeConversation?.insert(message, completionHandler: { error in
            if let error = error {
                print("❌ Failed to send event message:", error)
            } else {
                print("✅ Event message sent!")
                self.showPollCreationView()
            }
        })
    }

    // MARK: - MSMessage Builder for Event
    /// Builds a visually rich, themed MSMessage for an Event.
    func buildEventMessage(with event: Event, in session: MSSession) -> MSMessage {
        // Properly configure the layout using property assignments
        let layout = MSMessageTemplateLayout()
        layout.caption = event.title
        layout.subcaption = event.location
        layout.trailingSubcaption = event.dateTime
        if let data = event.imageData {
            layout.image = UIImage(data: data)
        }
        layout.trailingCaption = "Reactions: \(event.reactions.map { "\($0.key): \($0.value)" }.joined(separator: ", "))"

        var message = MSMessage(session: session)
        message.layout = layout

        if let data = try? JSONEncoder().encode(event) {
            let base64 = data.base64EncodedString()
            if var components = URLComponents(string: "https://gather.event") {
                components.queryItems = [URLQueryItem(name: "data", value: base64)]
                message.url = components.url
            }
        }
        return message
    }
    
//    func showSchedulerViewController() {
//        let schedulerVC = SchedulerViewController()
//        schedulerVC.modalPresentationStyle = .formSheet // or .fullScreen if you prefer
//        present(schedulerVC, animated: true, completion: nil)
//    }

    // MARK: - PHPickerViewControllerDelegate
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        dismiss(animated: true)
        guard let provider = results.first?.itemProvider, provider.canLoadObject(ofClass: UIImage.self) else { return }
        provider.loadObject(ofClass: UIImage.self) { object, error in
            DispatchQueue.main.async {
                if let image = object as? UIImage {
                    self.selectedImage = image
                    self.imageButton.setTitle("Image Selected", for: .normal)
                }
            }
        }
    }

}

// MARK: - Build MSMessage from Event (convenience)
extension MessagesViewController {
    /// Builds an MSMessage for the given Event, encoding its data as a base64 query parameter.
    func buildMessage(from event: Event) -> MSMessage {
        let layout = MSMessageTemplateLayout()
        layout.caption = event.title
        layout.subcaption = "\(event.location) • \(event.dateTime)"
        layout.image = event.uiImage
        layout.trailingCaption = "Reactions: \(event.reactions.map { "\($0.key): \($0.value)" }.joined(separator: ", "))"
        layout.trailingSubcaption = event.details

        let encoder = JSONEncoder()
        guard let data = try? encoder.encode(event),
              let base64String = data.base64EncodedString().addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "https://gather.event?data=\(base64String)") else {
            fatalError("Failed to encode event")
        }

        let message = MSMessage()
        message.layout = layout
        message.url = url
        return message
    }
}

// MARK: - Update Existing Message
extension MessagesViewController {
    func update(message: MSMessage) {
        self.activeConversation?.insert(message, completionHandler: { error in
            if let error = error {
                print("❌ Failed to update message: \(error)")
            } else {
                print("✅ Message updated successfully!")
            }
        })
    }
}

extension UITextField {
    func setLeftPaddingPoints(_ amount:CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
    func setRightPaddingPoints(_ amount:CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.height))
        self.rightView = paddingView
        self.rightViewMode = .always
    }
}

extension UIColor {
    func withHueOffset(_ offset: CGFloat) -> UIColor {
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        var alpha: CGFloat = 0
        if getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha) {
            hue = fmod(hue + offset, 1.0)
            return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: alpha)
        }
        return self
    }
    
}


