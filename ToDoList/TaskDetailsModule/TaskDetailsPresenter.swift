//
//  TaskDetailsPresenter.swift
//  ToDoList
//
//  Created by Kirill Pukhov on 23.02.2025.
//

import Foundation

protocol TaskDetailsPresenterProtocol: AnyObject {
    var taskTitle: String { get set }
    var taskDate: String { get set }
    var taskDescription: String { get set }

    func didEndTitleEditing()
    func didEndDescriptionEditing()

    func viewDidLoad()
    func viewWillAppear()
    func viewWillDisappear()
}

final class TaskDetailsPresenter: TaskDetailsPresenterProtocol {
    weak var view: TaskDetailsViewProtocol?
    var interactor: TaskDetailsInteractorInputProtocol
    var router: TaskDetailsRouter

    var taskTitle: String = ""
    var taskDate: String = ""
    var taskDescription: String = ""

    private static var dateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        return dateFormatter
    }()

    init(interactor: TaskDetailsInteractorInputProtocol, router: TaskDetailsRouter) {
        self.interactor = interactor
        self.router = router
    }

    func viewDidLoad() {
        interactor.viewDidLoad()
    }

    func viewWillAppear() {
        taskTitle = interactor.taskEntity.title
        taskDescription = interactor.taskEntity.description
        taskDate = TaskDetailsPresenter.dateFormatter.string(from: interactor.taskEntity.date)
    }

    func viewWillDisappear() {
        interactor.viewWillDisappear()
    }

    func didEndTitleEditing() {
        interactor.updateTaskTitle(taskTitle)
    }

    func didEndDescriptionEditing() {
        interactor.updateTaskDescription(taskDescription)
    }
}

extension TaskDetailsPresenter: TaskDetailsInteractorOutputProtocol {
    func didFailToLoadTask() {
        guard let view else { return }

        router.navigateBack(view: view)
    }
}
