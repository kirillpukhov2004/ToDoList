//
//  TaskDetailsRouter.swift
//  ToDoList
//
//  Created by Kirill Pukhov on 23.02.2025.
//

import Foundation
import UIKit

protocol TaskDetailsRouterProtocol: AnyObject {
    static func createModule(taskID: UUID?, delegate: TaskDetailsDelegate) -> TaskDetailsViewController

    func navigateBack(view: TaskDetailsViewProtocol)
}

final class TaskDetailsRouter: TaskDetailsRouterProtocol {
    static func createModule(taskID: UUID?, delegate: TaskDetailsDelegate) -> TaskDetailsViewController {
        let interactor = TaskDetailsInteractor(taskID: taskID, coreDataService: .shared)
        interactor.delegate = delegate
        let router = TaskDetailsRouter()
        let presenter = TaskDetailsPresenter(interactor: interactor, router: router)
        interactor.presenter = presenter
        let view = TaskDetailsViewController(presenter: presenter)
        presenter.view = view

        return view
    }

    func navigateBack(view: any TaskDetailsViewProtocol) {
        guard
            let view = view as? TaskDetailsViewController,
            let navigationController = view.navigationController
        else { return }

        navigationController.popViewController(animated: true)
    }
}
