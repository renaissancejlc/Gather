//
//  MessagesViewController.swift
//  Gather MessagesExtension
//
//  Created by Renaissance Carr on 6/1/25.
//

import UIKit
import Messages

class MessagesViewController: MSMessagesAppViewController {
    

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

        let questionField = UITextField()
        questionField.placeholder = "Enter your poll question here..."
        questionField.borderStyle = .none
        questionField.backgroundColor = UIColor.systemGray6
        questionField.textColor = .electricViolet
        questionField.font = UIFont.boldSystemFont(ofSize: 18)
        questionField.layer.cornerRadius = 10
        questionField.layer.masksToBounds = true
        questionField.layer.borderColor = UIColor.electricViolet.cgColor
        questionField.layer.borderWidth = 1.5
        questionField.setLeftPaddingPoints(12)
        questionField.setRightPaddingPoints(12)

        var optionFields: [UITextField] = []
        for i in 0..<5 {
            let option = UITextField()
            option.placeholder = "Option \(i + 1)"
            option.borderStyle = .roundedRect
            optionFields.append(option)
        }

        let sendButton = UIButton(type: .system)
        sendButton.setTitle("Send Poll", for: .normal)
        sendButton.addTarget(self, action: #selector(sendPollButtonTapped(_:)), for: .touchUpInside)

        let stack = UIStackView(arrangedSubviews: [questionField] + optionFields + [sendButton])
        stack.axis = .vertical
        stack.spacing = 10
        stack.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stack.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.85)
        ])

        stack.tag = 999 // use to retrieve later
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
        print("🧪 didReceive fired! PresentationStyle: \(presentationStyle.rawValue)")
        print("📬 Full message: \(message)")
        print("📬 Message URL: \(String(describing: message.url))")
        if let session = message.session {
            print("📨 Message session: \(session.debugDescription)")
        }
        if let layout = message.layout as? MSMessageTemplateLayout {
            print("🖼 Caption: \(layout.caption ?? "nil")")
            print("🖼 Subcaption: \(layout.subcaption ?? "nil")")
        }

        if message.url == nil {
            if let layout = message.layout as? MSMessageTemplateLayout {
                print("🧩 Message has layout but no URL. Caption: \(layout.caption ?? "nil")")
            }
            print("⚠️ Message had no URL. This usually means the poll was not sent with attached data.")
        }

        guard let url = message.url else {
            print("⚠️ No URL found in message")
            return
        }

        print("📦 URL from message: \(url.absoluteString)")

        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let dataQuery = components.queryItems?.first(where: { $0.name == "data" }),
              let base64 = dataQuery.value,
              let data = Data(base64Encoded: base64) else {
            print("❌ Failed to decode base64 poll data")
            return
        }

        print("🔍 Decoding base64 data from URL: \(base64.prefix(50))...")

        do {
            let poll = try JSONDecoder().decode(Poll.self, from: data)
            print("✅ Decoded poll: \(poll.question)")
            let alreadyVoted = poll.hasVoted(userID: localUserID)
            showPollCard(poll, allowVoting: !alreadyVoted)
        } catch {
            print("❌ JSON decode failed: \(error)")
        }
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
        guard let url = encodePollToURL(poll) else { return }
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

        let message = MSMessage(session: originalMessage?.session ?? conversation.selectedMessage?.session ?? MSSession())
        message.summaryText = "Poll: \(poll.question)"
        message.layout = layout
        message.url = url
        message.accessibilityLabel = url.absoluteString

        conversation.insert(message) { error in
            if let error = error {
                print("❌ Error sending message: \(error.localizedDescription)")
            } else {
                print("✅ Poll message sent!")
            }
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
