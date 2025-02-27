//
//  TaskListViewController.swift
//  ToDoList
//
//  Created by Kirill Pukhov on 21.02.2025.
//

import Foundation
import UIKit

protocol TaskListViewProtocol: AnyObject {
    func showTasks()
    func moveTask(at indexPath: IndexPath, to newIndexPath: IndexPath)

    func performBatchUpdates(
        insertIndexPaths: Set<IndexPath>,
        deleteIndexPaths: Set<IndexPath>,
        updateIndexPaths: Set<IndexPath>
    )

    func showActivityIndicator()
    func hideActivityIndicator()
}

class TaskListViewController: UIViewController, TaskListViewProtocol {
    private static let collectionViewLayout: UICollectionViewLayout = {
        let listConfiguration = UICollectionLayoutListConfiguration(appearance: .plain)
        let layout = UICollectionViewCompositionalLayout.list(using: listConfiguration)
        return layout
    }()

    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(
            frame: .zero, collectionViewLayout: TaskListViewController.collectionViewLayout)
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")

        return collectionView
    }()

    private lazy var numberOfUncompletedTasksLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13)
        label.textAlignment = .center
        return label
    }()

    private lazy var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = .large
        return activityIndicator
    }()

    private let presenter: TaskListPresenterProtocol

    init(presenter: TaskListPresenter) {
        self.presenter = presenter

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.isToolbarHidden = false

        presenter.viewWillAppear()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        presenter.viewWillDisappear()
    }

    private func setupUI() {
        view.backgroundColor = .systemBackground

        navigationItem.title = "Задачи"
        toolbarItems = [
            UIBarButtonItem(systemItem: .flexibleSpace),
            UIBarButtonItem(customView: numberOfUncompletedTasksLabel),
            UIBarButtonItem(systemItem: .flexibleSpace),
            UIBarButtonItem(
                image: UIImage(systemName: "square.and.pencil"),
                primaryAction: UIAction { [weak self] _ in
                    self?.presenter.createTaskButtonAction()
                }
            ),
        ]

        if let contextMenuViewClass = NSClassFromString("_UIContextMenuView") as? UIView.Type {
            contextMenuViewClass.appearance().overrideUserInterfaceStyle = .light
        }

        numberOfUncompletedTasksLabel.text = "0 Задач"

        collectionView.dataSource = self
        collectionView.delegate = self
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.leftAnchor.constraint(equalTo: view.leftAnchor),
            collectionView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
            collectionView.rightAnchor.constraint(equalTo: view.rightAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])

        view.addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor)
        ])
    }

    private func updateNumberOfUncompletedTasksLabelText() {
        numberOfUncompletedTasksLabel.text = "\(presenter.numberOfUncompletedTasks) Задач"
        numberOfUncompletedTasksLabel.sizeToFit()
    }

    // MARK: - ToDoListViewProtocol Implementation

    func showTasks() {
        collectionView.reloadData()
        updateNumberOfUncompletedTasksLabelText()
    }

    func insertTask(at indexPath: IndexPath) {
        collectionView.insertItems(at: [indexPath])
        updateNumberOfUncompletedTasksLabelText()
    }

    func deleteTask(at indexPath: IndexPath) {
        collectionView.deleteItems(at: [indexPath])
        updateNumberOfUncompletedTasksLabelText()
    }

    func moveTask(at indexPath: IndexPath, to newIndexPath: IndexPath) {
        collectionView.moveItem(at: indexPath, to: newIndexPath)
        updateNumberOfUncompletedTasksLabelText()
    }

    func updateTask(at indexPath: IndexPath) {
        collectionView.reloadItems(at: [indexPath])
        updateNumberOfUncompletedTasksLabelText()
    }

    func performBatchUpdates(
        insertIndexPaths: Set<IndexPath>,
        deleteIndexPaths: Set<IndexPath>,
        updateIndexPaths: Set<IndexPath>
    ) {
        collectionView.performBatchUpdates {
            collectionView.insertItems(at: Array(insertIndexPaths))
            collectionView.deleteItems(at: Array(deleteIndexPaths))
            collectionView.reloadItems(at: Array(updateIndexPaths))
        } completion: { [weak self] _ in
            self?.updateNumberOfUncompletedTasksLabelText()
        }
    }

    func showActivityIndicator() {
        collectionView.isHidden = true
        activityIndicator.startAnimating()
    }

    func hideActivityIndicator() {
        collectionView.isHidden = false
        activityIndicator.stopAnimating()
    }
}

extension TaskListViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return presenter.numberOfTasks
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "cell",
            for: indexPath
        )

        let taskEntity = presenter.getTask(for: indexPath)
        let contentConfiguration = TaskListContentConfiguration(
            title: taskEntity.title,
            description: taskEntity.description,
            date: taskEntity.date,
            isCompleted: taskEntity.isCompleted
        ) { [weak self] in
            self?.presenter.toggleTaskCompletion(at: indexPath)
        }

        cell.contentConfiguration = contentConfiguration
        return cell
    }
}

extension TaskListViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        presenter.taskSelectionAction(for: indexPath)
    }

    func collectionView(
        _ collectionView: UICollectionView, contextMenuConfigurationForItemsAt indexPaths: [IndexPath], point: CGPoint
    ) -> UIContextMenuConfiguration? {
        let taskEntity = presenter.getTask(for: indexPaths[0])

        return UIContextMenuConfiguration(identifier: nil) {
            let previewProvider = TaskListContextMenuContentPreviewProvider()
            previewProvider.configure(for: taskEntity)

            return previewProvider
        } actionProvider: { action in
            let edit = UIAction(title: "Редактировать", image: UIImage(named: "edit")) { [weak self] _ in
                self?.presenter.taskContextMenuItemAction(for: indexPaths[0], menuItem: .edit)
            }

            let export = UIAction(title: "Поделиться", image: UIImage(named: "export")) { [weak self] _ in
                self?.presenter.taskContextMenuItemAction(for: indexPaths[0], menuItem: .share)
            }

            let delete = UIAction(title: "Удалить", image: UIImage(named: "trash"), attributes: .destructive) {
                [weak self] _ in
                self?.presenter.taskContextMenuItemAction(for: indexPaths[0], menuItem: .delete)
            }

            return UIMenu(children: [edit, export, delete])
        }
    }
}
