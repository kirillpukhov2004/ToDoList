//
//  TaskListContextMenuContentPreviewProvider.swift
//  ToDoList
//
//  Created by Kirill Pukhov on 26.02.2025.
//

import Foundation
import UIKit

final class TaskListContextMenuContentPreviewProvider: UIViewController {
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.numberOfLines = 1
        return label
    }()

    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.numberOfLines = 2
        return label
    }()

    private lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .white.withAlphaComponent(0.5)
        return label
    }()

    private lazy var dateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        return dateFormatter
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }

    private func setupUI() {
        view.backgroundColor = UIColor(red: 39/255, green: 39/255, blue: 39/255, alpha: 1)

        preferredContentSize = CGSize(width: 320, height: 106)

        view.layer.cornerRadius = 12
        view.layer.masksToBounds = true

        view.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 12),
            titleLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16),
            titleLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16),
        ])

        view.addSubview(descriptionLabel)
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 6),
            descriptionLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16),
            descriptionLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16),
        ])

        view.addSubview(dateLabel)
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            dateLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 6),
            dateLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16),
            dateLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -12),
            dateLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16),
        ])
    }

    func configure(for taskEntity: TaskEntity) {
        titleLabel.text = taskEntity.title
        descriptionLabel.text = taskEntity.description
        dateLabel.text = dateFormatter.string(from: taskEntity.date)
    }
}
