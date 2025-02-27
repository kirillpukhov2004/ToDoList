//
//  TaskListPresenter.swift
//  ToDoList
//
//  Created by Kirill Pukhov on 21.02.2025.
//

import Foundation

enum TaskListContextMenuItem {
    case edit
    case share
    case delete
}

protocol TaskListPresenterProtocol: AnyObject {
    var numberOfTasks: Int { get }
    var numberOfUncompletedTasks: Int { get }

    func viewWillAppear()
    func viewWillDisappear()

    func toggleTaskCompletion(at indexPath: IndexPath)

    func createTaskButtonAction()
    func taskSelectionAction(for indexPath: IndexPath)
    func taskContextMenuItemAction(for indexPath: IndexPath, menuItem: TaskListContextMenuItem)

    func getTask(for indexPath: IndexPath) -> TaskEntity
}

class TaskListPresenter: TaskListPresenterProtocol {
    weak var view: TaskListViewProtocol?
    var interactor: TaskListInteractorInputProtocol
    var router: TaskListRouterProtocol

    var numberOfTasks: Int {
        interactor.numberOfTasks
    }

    var numberOfUncompletedTasks: Int {
        interactor.numberOfUncompletedTasks
    }

    init(interactor: TaskListInteractorInputProtocol, router: TaskListRouterProtocol) {
        self.interactor = interactor
        self.router = router
    }

    func viewWillAppear() {
        interactor.viewWillAppear()
    }

    func viewWillDisappear() {
        interactor.viewWillDisappear()
    }

    func toggleTaskCompletion(at indexPath: IndexPath) {
        interactor.toggleTaskCompletion(at: indexPath)
    }

    func createTaskButtonAction() {
        guard let view else { return }

        router.navigateToTaskCreation(view: view)
    }

    func taskSelectionAction(for indexPath: IndexPath) {
        guard let view else { return }

        let taskEntity = getTask(for: indexPath)

        router.navigateToTaskDetails(view: view, taskID: taskEntity.id)
    }

    func taskContextMenuItemAction(for indexPath: IndexPath, menuItem: TaskListContextMenuItem) {
        switch menuItem {
        case .edit:
            guard let view else { return }

            let taskEntity = getTask(for: indexPath)

            router.navigateToTaskDetails(view: view, taskID: taskEntity.id)
        case .share:
            break
        case .delete:
            interactor.deleteTask(at: indexPath)
        }
    }

    func getTask(for indexPath: IndexPath) -> TaskEntity {
        interactor.getTask(for: indexPath)
    }
}

extension TaskListPresenter: TaskListInteractorOutputProtocol {
    func didFetchTasks() {
        view?.showTasks()
    }

    func didMoveTask(at indexPath: IndexPath, to newIndexPath: IndexPath) {
        view?.moveTask(at: indexPath, to: newIndexPath)
    }

    func didPerformBatchUpdates(
        insertIndexPaths: Set<IndexPath>,
        deleteIndexPaths: Set<IndexPath>,
        updateIndexPaths: Set<IndexPath>
    ) {
        view?.performBatchUpdates(
            insertIndexPaths: insertIndexPaths,
            deleteIndexPaths: deleteIndexPaths,
            updateIndexPaths: updateIndexPaths
        )
    }

    func willStartInitialFetch() {
        view?.showActivityIndicator()
    }

    func didFinishInitialFetch() {
        view?.hideActivityIndicator()
    }
}
