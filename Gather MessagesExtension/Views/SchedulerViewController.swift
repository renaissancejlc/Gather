//
//  SchedulerViewController.swift
//  Gather
//
//  Created by Renaissance Carr on 6/1/25.
//


import UIKit

class SchedulerViewController: UIViewController {

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Create a Schedule"
        label.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        label.textAlignment = .center
        return label
    }()

    private let startDatePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .compact
        return picker
    }()

    private let endDatePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .compact
        return picker
    }()

    private let instructionLabel: UILabel = {
        let label = UILabel()
        label.text = "Mark your availability for each day."
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 16)
        return label
    }()

    private let submitButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Continue", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.backgroundColor = UIColor.systemPurple
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupLayout()
        submitButton.addTarget(self, action: #selector(handleSubmit), for: .touchUpInside)
    }

    private func setupLayout() {
        [titleLabel, startDatePicker, endDatePicker, instructionLabel, submitButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            startDatePicker.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            startDatePicker.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            endDatePicker.topAnchor.constraint(equalTo: startDatePicker.bottomAnchor, constant: 10),
            endDatePicker.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            instructionLabel.topAnchor.constraint(equalTo: endDatePicker.bottomAnchor, constant: 20),
            instructionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            instructionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            submitButton.topAnchor.constraint(equalTo: instructionLabel.bottomAnchor, constant: 30),
            submitButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            submitButton.widthAnchor.constraint(equalToConstant: 180),
            submitButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }

    @objc func handleSubmit() {
        let startDate = startDatePicker.date
        let endDate = endDatePicker.date

        // Initialize timeSlots as empty
        var timeSlots: [String: [String: Bool]] = [:]

        // Create the Schedule object
        let schedule = Schedule(
            id: UUID().uuidString,
            startDate: startDate,
            endDate: endDate,
            timeSlots: timeSlots
        )

        // Placeholder for message send logic
        print("✅ Schedule created: \(schedule)")
        // You can call your message send or navigation logic here
    }
}
