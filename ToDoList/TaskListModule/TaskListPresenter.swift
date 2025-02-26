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
    func viewDidLoad()

    func createTaskButtonAction()

    func toggleToDoItemCompletion(_ taskID: UUID)

    func taskSelectionAction(_ taskID: UUID)

    func taskContextMenuItemAction(_ taskID: UUID, menuItem: TaskListContextMenuItem)
}

class TaskListPresenter: TaskListPresenterProtocol {
    weak var view: TaskListViewProtocol?
    var interactor: TaskListInteractorInputProtocol
    var router: TaskListRouterProtocol

    init(interactor: TaskListInteractorInputProtocol, router: TaskListRouterProtocol) {
        self.interactor = interactor
        self.router = router
    }

    func viewDidLoad() {
        interactor.fetchTasks()
    }

    func toggleToDoItemCompletion(_ taskID: UUID) {
        interactor.toggleTaskCompletion(taskID)
    }

    func createTaskButtonAction() {
        guard
            let view,
            let interactor = interactor as? TaskListInteractor
        else { return }

        router.navigateToTaskCreation(view: view, delegate: interactor)
    }

    func taskSelectionAction(_ taskID: UUID) {
        guard
            let view,
            let interactor = interactor as? TaskListInteractor
        else { return }

        router.navigateToTaskDetails(view: view, taskID: taskID, delegate: interactor)
    }

    func taskContextMenuItemAction(_ taskID: UUID, menuItem: TaskListContextMenuItem) {
        switch menuItem {
        case .edit:
            guard
                let view,
                let interactor = interactor as? TaskListInteractor
            else { return }

            router.navigateToTaskDetails(view: view, taskID: taskID, delegate: interactor)
        case .share:
            break
        case .delete:
            interactor.deleteTask(taskID)
        }
    }
}

extension TaskListPresenter: TaskListInteractorOutputProtocol {
    func didFetchTasks(_ result: Result<[TaskEntity], any Error>) {
        switch result {
        case .success(let taskEntities):
            view?.showTasks(taskEntities)
        case .failure(let error):
            print(error)
        }
    }

    func didToggleTaskCompletion(_ task: TaskEntity) {
        view?.updateTask(task)
    }

    func didCreateTask(_ taskEntity: TaskEntity) {
        view?.showNewTask(taskEntity)
    }

    func didUpdateTask(_ taskEntity: TaskEntity) {
        view?.updateTask(taskEntity)
    }

    func didDeleteTask(_ taskID: UUID) {
        view?.deleteTask(taskID)
    }
}
