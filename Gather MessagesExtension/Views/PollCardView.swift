import UIKit

extension UIColor {
    static let electricViolet = UIColor(red: 143/255, green: 0/255, blue: 255/255, alpha: 1.0)
    static let electricVioletText = UIColor.white
}

class PollCardView: UIView {

    private let questionLabel = UILabel()
    private var poll: Poll!
    private var isInteractive: Bool = true
    private var showResults: Bool = false
    private var onVote: ((Int) -> Void)?
    private var selectedIndices: Set<Int> = []
    private var optionButtons: [UIButton] = []

    init(poll: Poll, isInteractive: Bool, showResults: Bool, onVote: ((Int) -> Void)? = nil) {
        super.init(frame: .zero)
        self.poll = poll
        self.isInteractive = isInteractive
        self.showResults = showResults
        self.onVote = onVote
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        backgroundColor = UIColor.systemGray6
        layer.cornerRadius = 12
        clipsToBounds = true

        questionLabel.text = poll.question
        questionLabel.font = UIFont.boldSystemFont(ofSize: 16)
        questionLabel.numberOfLines = 0

        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 12

        if showResults {
            let totalVotes = max(1, poll.options.map { $0.votes }.reduce(0, +))
            for (index, option) in poll.options.enumerated() {
                let percentage = Float(option.votes) / Float(totalVotes)
                let barContainer = UIView()
                barContainer.backgroundColor = .systemGray4
                barContainer.layer.cornerRadius = 6
                barContainer.clipsToBounds = true
                barContainer.heightAnchor.constraint(equalToConstant: 24).isActive = true

                let bar = UIView()
                bar.backgroundColor = .electricViolet
                bar.frame = CGRect(x: 0, y: 0, width: 0, height: 24)
                bar.alpha = 0.0
                barContainer.addSubview(bar)

                let label = UILabel()
                label.text = "\(option.text) (\(option.votes))"
                label.font = UIFont.systemFont(ofSize: 14)
                label.alpha = 0.0

                let hStack = UIStackView(arrangedSubviews: [label, barContainer])
                hStack.axis = .horizontal
                hStack.spacing = 12
                hStack.alignment = .center

                stack.addArrangedSubview(hStack)

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1 * Double(index)) {
                    UIView.animate(withDuration: 0.6) {
                        bar.frame.size.width = barContainer.frame.width * CGFloat(percentage)
                        bar.alpha = 1.0
                        label.alpha = 1.0
                    }
                }
            }
            // Add summary bar chart
            let chartContainer = UIView()
            chartContainer.heightAnchor.constraint(equalToConstant: 100).isActive = true
            chartContainer.layer.cornerRadius = 8
            chartContainer.clipsToBounds = true

            let chartStack = UIStackView()
            chartStack.axis = .horizontal
            chartStack.distribution = .fillProportionally
            chartStack.spacing = 4
            chartStack.translatesAutoresizingMaskIntoConstraints = false
            chartContainer.addSubview(chartStack)

            NSLayoutConstraint.activate([
                chartStack.topAnchor.constraint(equalTo: chartContainer.topAnchor),
                chartStack.bottomAnchor.constraint(equalTo: chartContainer.bottomAnchor),
                chartStack.leadingAnchor.constraint(equalTo: chartContainer.leadingAnchor),
                chartStack.trailingAnchor.constraint(equalTo: chartContainer.trailingAnchor),
            ])

            for option in poll.options {
                let percentage = CGFloat(option.votes) / CGFloat(totalVotes)
                
                let slice = UIView()
                slice.backgroundColor = .systemGray5
                slice.layer.cornerRadius = 4
                slice.clipsToBounds = true

                let barView = UIView()
                barView.backgroundColor = .electricViolet
                barView.alpha = 0.8
                barView.translatesAutoresizingMaskIntoConstraints = false
                slice.addSubview(barView)

                NSLayoutConstraint.activate([
                    barView.topAnchor.constraint(equalTo: slice.topAnchor),
                    barView.bottomAnchor.constraint(equalTo: slice.bottomAnchor),
                    barView.leadingAnchor.constraint(equalTo: slice.leadingAnchor),
                    barView.widthAnchor.constraint(equalTo: slice.widthAnchor, multiplier: percentage)
                ])

                chartStack.addArrangedSubview(slice)
            }

            stack.addArrangedSubview(chartContainer)
        } else {
            for (index, option) in poll.options.enumerated() {
                let button = UIButton(type: .system)
                button.setTitle(option.text, for: .normal)
                button.backgroundColor = .electricViolet
                button.setTitleColor(.electricVioletText, for: .normal)
                button.layer.cornerRadius = 8
                button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
                button.isEnabled = isInteractive
                button.alpha = isInteractive ? 1.0 : 0.6
                button.tag = index
                button.addTarget(self, action: #selector(optionTapped(_:)), for: .touchUpInside)
                stack.addArrangedSubview(button)
                optionButtons.append(button)
            }
            if poll.isMultiSelect {
                let submitButton = UIButton(type: .system)
                submitButton.setTitle("Submit Vote", for: .normal)
                submitButton.backgroundColor = .systemBlue
                submitButton.setTitleColor(.white, for: .normal)
                submitButton.layer.cornerRadius = 8
                submitButton.contentEdgeInsets = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
                submitButton.addTarget(self, action: #selector(submitMultiVote), for: .touchUpInside)
                stack.addArrangedSubview(submitButton)
            }
        }

        let vstack = UIStackView(arrangedSubviews: [questionLabel, stack])
        vstack.axis = .vertical
        vstack.spacing = 16
        vstack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(vstack)

        NSLayoutConstraint.activate([
            vstack.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            vstack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12),
            vstack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            vstack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
        ])
    }

    @objc private func optionTapped(_ sender: UIButton) {
        guard isInteractive else { return }
        
        UIView.animate(withDuration: 0.15, animations: {
            sender.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }, completion: { _ in
            UIView.animate(withDuration: 0.15) {
                sender.transform = .identity
            }
        })
        
        let index = sender.tag
        if poll.isMultiSelect {
            if selectedIndices.contains(index) {
                selectedIndices.remove(index)
                sender.alpha = 0.6
                sender.backgroundColor = .electricViolet
                sender.setTitleColor(.electricVioletText, for: .normal)
            } else {
                selectedIndices.insert(index)
                sender.alpha = 1.0
                sender.backgroundColor = .systemGreen
                sender.setTitleColor(.electricVioletText, for: .normal)
            }
        } else {
            onVote?(index)
        }
    }

    @objc private func submitMultiVote() {
        for index in selectedIndices {
            onVote?(index)
        }
    }
}
