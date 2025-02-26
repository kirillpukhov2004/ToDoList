//
//  TaskListContentView.swift
//  ToDoList
//
//  Created by Kirill Pukhov on 22.02.2025.
//

import Foundation
import UIKit

final class TaskListContentView: UIView, UIContentView {
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.numberOfLines = 2
        return label
    }()

    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 12)
        label.numberOfLines = 2
        return label
    }()

    private lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 12)
        label.textColor = .init(red: 244 / 255, green: 244 / 255, blue: 244 / 255, alpha: 0.5)
        return label
    }()

    private lazy var checkmarkView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private lazy var dateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        return dateFormatter
    }()

    private lazy var tapGestureRecognizer = {
        let gestureRecognizer = UITapGestureRecognizer()
        gestureRecognizer.numberOfTapsRequired = 1
        gestureRecognizer.addTarget(self, action: #selector(checkmarkTapGestureRecognizerAction))
        return gestureRecognizer
    }()

    var configuration: UIContentConfiguration {
        willSet {
            guard let configuration = newValue as? TaskListContentConfiguration else { return }

            configure(configuration: configuration)
        }
    }

    init(configuration: TaskListContentConfiguration) {
        self.configuration = configuration

        super.init(frame: .zero)

        addSubview(checkmarkView)
        NSLayoutConstraint.activate([
            checkmarkView.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            checkmarkView.leftAnchor.constraint(equalTo: leftAnchor, constant: 20),
            checkmarkView.widthAnchor.constraint(equalToConstant: 24),
            checkmarkView.heightAnchor.constraint(equalToConstant: 24),
        ])

        checkmarkView.isUserInteractionEnabled = true
        checkmarkView.addGestureRecognizer(tapGestureRecognizer)

        addSubview(titleLabel)
        titleLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            titleLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -20),
            titleLabel.leftAnchor.constraint(equalTo: checkmarkView.rightAnchor, constant: 8),
        ])

        addSubview(descriptionLabel)
        let descriptionLabelTopAnchor = descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 6)
        descriptionLabelTopAnchor.priority = .defaultHigh
        NSLayoutConstraint.activate([
            descriptionLabelTopAnchor,
            descriptionLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -20),
            descriptionLabel.leftAnchor.constraint(equalTo: checkmarkView.rightAnchor, constant: 8),
        ])

        addSubview(dateLabel)
        dateLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        let dateLabelFirstTopAnchor = dateLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 6)
        dateLabelFirstTopAnchor.priority = .defaultHigh
        let dateLabelSecondTopAnchor = dateLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 6)
        dateLabelSecondTopAnchor.priority = .defaultLow
        NSLayoutConstraint.activate([
            dateLabelFirstTopAnchor,
            dateLabelSecondTopAnchor,
            dateLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -20),
            dateLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12),
            dateLabel.leftAnchor.constraint(equalTo: checkmarkView.rightAnchor, constant: 8),
        ])

        configure(configuration: configuration)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configure(configuration: TaskListContentConfiguration) {
        titleLabel.text = configuration.title
        descriptionLabel.text = configuration.description
        dateLabel.text = dateFormatter.string(from: configuration.date)
        checkmarkView.image =
            configuration.isCompleted ? UIImage(named: "checkmark-checked") : UIImage(named: "checkmark-unchecked")
    }

    @objc
    private func checkmarkTapGestureRecognizerAction() {
        guard let configuration = configuration as? TaskListContentConfiguration else { return }
        
        configuration.checkmarkTapGestureAction()
    }
}
