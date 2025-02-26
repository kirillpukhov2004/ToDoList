//
//  TaskDetailsViewController.swift
//  ToDoList
//
//  Created by Kirill Pukhov on 23.02.2025.
//

import Foundation
import UIKit

protocol TaskDetailsViewProtocol: AnyObject {

}

final class TaskDetailsViewController: UIViewController, TaskDetailsViewProtocol {
    private lazy var titleTextView: UITextView = {
        let textView = UITextView()
        textView.delegate = self
        textView.font = .systemFont(ofSize: 34, weight: .bold)
        textView.isScrollEnabled = false
        textView.textContainerInset = .init(top: 8, left: 20, bottom: 0, right: 20)
        textView.textContainer.lineFragmentPadding = 0
        return textView
    }()

    private lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(red: 244 / 255, green: 244 / 255, blue: 244 / 255, alpha: 0.5)
        return label
    }()

    private lazy var descriptionTextView: UITextView = {
        let textView = UITextView()
        textView.delegate = self
        textView.font = .systemFont(ofSize: 16)
        textView.isScrollEnabled = true
        textView.textContainerInset = .init(top: 0, left: 20, bottom: 0, right: 20)
        textView.textContainer.lineFragmentPadding = 0
        return textView
    }()

    private let presenter: TaskDetailsPresenterProtocol

    init(presenter: TaskDetailsPresenterProtocol) {
        self.presenter = presenter

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        presenter.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        presenter.viewWillAppear()

        navigationController?.navigationBar.prefersLargeTitles = false
        navigationController?.isToolbarHidden = true

        if presenter.taskTitle.isEmpty {
            titleTextView.text = "Заголовок"
            titleTextView.textColor = .placeholderText
        } else {
            titleTextView.text = presenter.taskTitle
            titleTextView.textColor = .label
        }

        dateLabel.text = presenter.taskDate

        if presenter.taskDescription.isEmpty {
            descriptionTextView.text = "Комментарии"
            descriptionTextView.textColor = .placeholderText
        } else {
            descriptionTextView.text = presenter.taskDescription
            descriptionTextView.textColor = .label
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        view.endEditing(true)
        presenter.viewWillDisappear()
    }

    private func setupUI() {
        view.backgroundColor = .systemBackground

        view.addSubview(titleTextView)
        titleTextView.translatesAutoresizingMaskIntoConstraints = false
        titleTextView.setContentCompressionResistancePriority(.required, for: .vertical)
        NSLayoutConstraint.activate([
            titleTextView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
            titleTextView.rightAnchor.constraint(equalTo: view.rightAnchor),
            titleTextView.leftAnchor.constraint(equalTo: view.leftAnchor)
        ])

        view.addSubview(dateLabel)
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            dateLabel.topAnchor.constraint(equalTo: titleTextView.bottomAnchor, constant: 8),
            dateLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20),
            dateLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
        ])

        view.addSubview(descriptionTextView)
        descriptionTextView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            descriptionTextView.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 16),
            descriptionTextView.rightAnchor.constraint(equalTo: view.rightAnchor),
            descriptionTextView.leftAnchor.constraint(equalTo: view.leftAnchor),
            descriptionTextView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}

extension TaskDetailsViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == .placeholderText {
            textView.text = nil
            textView.textColor = .label
        }

        let barButton = UIBarButtonItem(
            systemItem: .done,
            primaryAction: UIAction { [weak self] _ in
                self?.view.endEditing(true)
            }
        )
        navigationItem.setRightBarButton(barButton, animated: true)
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            switch textView {
            case titleTextView:
                textView.text = "Заголовок"
            case descriptionTextView:
                textView.text = "Комментарии"
            default:
                textView.text = nil
            }
            textView.textColor = .placeholderText
        } else {
            switch textView {
            case titleTextView:
                presenter.didEndTitleEditing()
            case descriptionTextView:
                presenter.didEndDescriptionEditing()
            default:
                break
            }
        }

        navigationItem.setRightBarButton(nil, animated: true)
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if textView == titleTextView {
            let forbiddenCharacters = CharacterSet(charactersIn: "\n\t")

            if text.rangeOfCharacter(from: forbiddenCharacters) != nil {
                return false
            }
        }

        return true
    }

    func textViewDidChange(_ textView: UITextView) {
        let text = textView.text ?? ""

        switch textView {
        case titleTextView:
            presenter.taskTitle = text
        case descriptionTextView:
            presenter.taskDescription = text
        default:
            break
        }
    }
}
