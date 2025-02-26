//
//  TaskDetailsInteractor.swift
//  ToDoList
//
//  Created by Kirill Pukhov on 23.02.2025.
//

import Foundation

protocol TaskDetailsInteractorInputProtocol: AnyObject {
    var taskEntity: TaskEntity { get }

    func updateTaskTitle(_ title: String)
    func updateTaskDescription(_ description: String)

    func viewDidLoad()
    func viewWillDisappear()
}

protocol TaskDetailsInteractorOutputProtocol: AnyObject {
    func didFailToLoadTask()
}

final class TaskDetailsInteractor: TaskDetailsInteractorInputProtocol {
    weak var presenter: TaskDetailsInteractorOutputProtocol?

    private let coreDataService: CoreDataService

    private let taskID: UUID?

    private var taskManagedObject: Task?
    var taskEntity: TaskEntity {
        guard let taskManagedObject else  {
            return .placeholder
        }

        return TaskEntity(taskManagedObject: taskManagedObject)
    }

    init(taskID: UUID?, coreDataService: CoreDataService) {
        self.coreDataService = coreDataService
        self.taskID = taskID
    }

    func updateTaskTitle(_ title: String) {
        taskManagedObject?.title = title

        coreDataService.saveManagedObjectContext()
    }

    func updateTaskDescription(_ description: String) {
        taskManagedObject?.descr = description

        coreDataService.saveManagedObjectContext()
    }

    func viewDidLoad() {
        if let taskID {
            let context = coreDataService.managedObjectContext

            let fetchRequest = Task.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %@", taskID.uuidString)

            do {
                taskManagedObject = try context.fetch(fetchRequest).first
            } catch {
                let nsError = error as NSError
                print("Unresolved error: \(nsError), \(nsError.userInfo)")
            }

            if taskManagedObject == nil {
                print("Task with ID \(taskID) not found")

                presenter?.didFailToLoadTask()
            }
        } else {
            taskManagedObject = Task(context: coreDataService.managedObjectContext)
        }
    }

    func viewWillDisappear() {
        if taskID == nil {
            guard !(taskManagedObject?.isInserted ?? true) else {
                coreDataService.managedObjectContext.rollback()
                return
            }
        }
    }
}
