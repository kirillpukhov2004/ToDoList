//
//  TaskListViewController.swift
//  ToDoList
//
//  Created by Kirill Pukhov on 21.02.2025.
//

import Foundation
import UIKit

protocol TaskListViewProtocol: AnyObject {
    func showTasks(_ taskEntities: [TaskEntity])
    func showNewTask(_ taskEntity: TaskEntity)
    func updateTask(_ taskEntity: TaskEntity)
    func deleteTask(_ taskID: UUID)
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
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")

        return collectionView
    }()

    private lazy var todoCountLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13)
        label.textAlignment = .center
        return label
    }()

    private let presenter: TaskListPresenterProtocol

    private var taskEntities: [TaskEntity] = [] {
        didSet {
            updateToDoCountLabelText()
        }
    }

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
        presenter.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.isToolbarHidden = false
    }

    private func setupUI() {
        view.backgroundColor = .systemBackground

        navigationItem.title = "Задачи"
        toolbarItems = [
            UIBarButtonItem(systemItem: .flexibleSpace),
            UIBarButtonItem(customView: todoCountLabel),
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

        todoCountLabel.text = "0 Задач"

        collectionView.dataSource = self
        collectionView.delegate = self
        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.leftAnchor.constraint(equalTo: view.leftAnchor),
            collectionView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
            collectionView.rightAnchor.constraint(equalTo: view.rightAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    private func updateToDoCountLabelText() {
        todoCountLabel.text = "\(taskEntities.filter({ !$0.isCompleted }).count) Задач"
        todoCountLabel.sizeToFit()
    }

    // MARK: - ToDoListViewProtocol Implementation

    func showTasks(_ taskEntities: [TaskEntity]) {
        self.taskEntities = taskEntities
        collectionView.reloadData()
        updateToDoCountLabelText()
    }

    func showNewTask(_ taskEntity: TaskEntity) {
        self.taskEntities.insert(taskEntity, at: 0)
        collectionView.insertItems(at: [IndexPath(row: 0, section: 0)])
    }

    func updateTask(_ taskEntity: TaskEntity) {
        if let index = taskEntities.firstIndex(where: { $0.id == taskEntity.id }) {
            taskEntities[index] = taskEntity
            collectionView.reloadItems(at: [IndexPath(row: index, section: 0)])
        }
    }

    func deleteTask(_ taskID: UUID) {
        guard let index = taskEntities.firstIndex(where: { $0.id == taskID }) else { return }
        taskEntities.remove(at: index)
        collectionView.deleteItems(at: [IndexPath(row: index, section: 0)])
    }
}

extension TaskListViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return taskEntities.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "cell",
            for: indexPath
        )

        let taskEntity = taskEntities[indexPath.row]
        let contentConfiguration = TaskListContentConfiguration(
            title: taskEntity.title,
            description: taskEntity.description,
            date: taskEntity.date,
            isCompleted: taskEntity.isCompleted
        ) { [weak self] in
            self?.presenter.toggleToDoItemCompletion(taskEntity.id)
        }

        cell.contentConfiguration = contentConfiguration
        return cell
    }
}

extension TaskListViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let taskID = taskEntities[indexPath.row].id

        presenter.taskSelectionAction(taskID)
    }

    func collectionView(
        _ collectionView: UICollectionView, contextMenuConfigurationForItemsAt indexPaths: [IndexPath], point: CGPoint
    ) -> UIContextMenuConfiguration? {
        let taskEntity = taskEntities[indexPaths[0].row]

        return UIContextMenuConfiguration(identifier: nil) {
            let previewProvider = TaskListContextMenuContentPreviewProvider()
            previewProvider.configure(for: taskEntity)

            return previewProvider
        } actionProvider: { action in
            let edit = UIAction(title: "Редактировать", image: UIImage(named: "edit")) { [weak self] _ in
                self?.presenter.taskContextMenuItemAction(taskEntity.id, menuItem: .edit)
            }

            let export = UIAction(title: "Поделиться", image: UIImage(named: "export")) { [weak self] _ in
                self?.presenter.taskContextMenuItemAction(taskEntity.id, menuItem: .share)
            }

            let delete = UIAction(title: "Удалить", image: UIImage(named: "trash"), attributes: .destructive) {
                [weak self] _ in
                self?.presenter.taskContextMenuItemAction(taskEntity.id, menuItem: .delete)
            }

            return UIMenu(children: [edit, export, delete])
        }
    }
}
