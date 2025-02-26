//
//  TaskListRouter.swift
//  ToDoList
//
//  Created by Kirill Pukhov on 21.02.2025.
//

import UIKit

protocol TaskListRouterProtocol: AnyObject {
    static func createModule() -> UIViewController

    func navigateToTaskCreation(view: TaskListViewProtocol)

    func navigateToTaskDetails(view: TaskListViewProtocol, taskID: UUID)
}

final class TaskListRouter: TaskListRouterProtocol {
    static func createModule() -> UIViewController {
        let interactor = TaskListInteractor(coreDataService: .shared, tasksAPI: DummyJsonAPIAdapter())
        let router = TaskListRouter()
        let presenter = TaskListPresenter(interactor: interactor, router: router)
        interactor.presenter = presenter
        let view = TaskListViewController(presenter: presenter)
        presenter.view = view

        return view
    }

    func navigateToTaskCreation(view: TaskListViewProtocol) {
        guard
            let viewController = view as? UIViewController,
            let navigationController = viewController.navigationController
        else {
            return
        }

        let taskDetailsViewController = TaskDetailsRouter.createModule(taskID: nil)
        navigationController.pushViewController(taskDetailsViewController, animated: true)
    }

    func navigateToTaskDetails(view: TaskListViewProtocol, taskID: UUID) {
        guard
            let viewController = view as? UIViewController,
            let navigationController = viewController.navigationController
        else {
            return
        }

        viewController.navigationItem.backButtonTitle = "Back"

        let taskDetailsViewController = TaskDetailsRouter.createModule(taskID: taskID)
        navigationController.pushViewController(taskDetailsViewController, animated: true)
    }
}
