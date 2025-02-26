//
//  TaskListInteractor.swift
//  ToDoList
//
//  Created by Kirill Pukhov on 21.02.2025.
//

import Foundation

protocol TaskListInteractorInputProtocol: AnyObject {
    func fetchTasks()
    func toggleTaskCompletion(_ taskID: UUID)
    func deleteTask(_ taskID: UUID)
}

protocol TaskListInteractorOutputProtocol: AnyObject {
    func didFetchTasks(_ result: Result<[TaskEntity], Error>)
    func didToggleTaskCompletion(_ task: TaskEntity)
    func didCreateTask(_ taskEntity: TaskEntity)
    func didUpdateTask(_ taskEntity: TaskEntity)
    func didDeleteTask(_ taskID: UUID)
}

final class TaskListInteractor: TaskListInteractorInputProtocol {
    weak var presenter: TaskListInteractorOutputProtocol?

    private let coreDataService: CoreDataService
    private let tasksAPI: TasksAPIProtocol

    var isInitialFetchCompleted: Bool {
        get {
            UserDefaults.standard.bool(forKey: "isInitialFetchCompleted")
        }

        set {
            UserDefaults.standard.set(newValue, forKey: "isInitialFetchCompleted")
        }
    }

    init(coreDataService: CoreDataService, tasksAPI: TasksAPIProtocol) {
        self.coreDataService = coreDataService
        self.tasksAPI = tasksAPI
    }

    func fetchTasks() {
        if isInitialFetchCompleted {
            regularFetchTasks()
        } else {
            initialFetchTasks()
        }
    }

    func toggleTaskCompletion(_ taskID: UUID) {
        let context = coreDataService.managedObjectContext

        let request = Task.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", taskID as CVarArg)

        do {
            if let taskManagedObject = try context.fetch(request).first {
                taskManagedObject.isCompleted.toggle()

                coreDataService.saveManagedObjectContext()

                let taskEntity = TaskEntity(taskManagedObject: taskManagedObject)
                presenter?.didToggleTaskCompletion(taskEntity)
            }
        } catch {
            let nsError = error as NSError
            print("Failed to toggle completion for task with id \(taskID): \(nsError) \(nsError.userInfo)")
        }
    }

    func deleteTask(_ taskID: UUID) {
        let context = coreDataService.managedObjectContext

        let request = Task.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", taskID as CVarArg)

        do {
            if let taskManagedObject = try context.fetch(request).first {
                context.delete(taskManagedObject)

                coreDataService.saveManagedObjectContext()

                presenter?.didDeleteTask(taskID)
            }
        } catch {
            let nsError = error as NSError
            print("Failed to delete task with id \(taskID.uuidString): \(nsError) \(nsError.userInfo)")
        }

    }

    private func initialFetchTasks() {
        tasksAPI.fetchTasks { [weak self] result in
            guard let self else { return }

            switch result {
            case .success(let taskEntities):
                let context = coreDataService.managedObjectContext

                taskEntities.forEach { taskEntity in
                    let taskManagedObject = Task(context: context)
                    taskManagedObject.id = taskEntity.id
                    taskManagedObject.title = taskEntity.title
                    taskManagedObject.descr = taskEntity.description
                    taskManagedObject.date = taskEntity.date
                    taskManagedObject.isCompleted = taskEntity.isCompleted
                }

                let sortedTasks = taskEntities.sorted { $0.date < $1.date }

                coreDataService.saveManagedObjectContext()
                isInitialFetchCompleted = true

                presenter?.didFetchTasks(.success(sortedTasks))
            case .failure(let error):
                isInitialFetchCompleted = true
                
                presenter?.didFetchTasks(.failure(error))
            }
        }
    }

    private func regularFetchTasks() {
        let context = coreDataService.managedObjectContext

        let request = Task.fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(key: "date", ascending: false),
            NSSortDescriptor(key: "title", ascending: false)
        ]

        do {
            let taskManagedObjects = try context.fetch(request)
            let taskEntities = taskManagedObjects.compactMap(TaskEntity.init)

            DispatchQueue.main.async { [weak self] in
                self?.presenter?.didFetchTasks(.success(taskEntities))
            }
        } catch {
            DispatchQueue.main.async { [weak self] in
                self?.presenter?.didFetchTasks(.failure(error))
            }
        }
    }
}

extension TaskListInteractor: TaskDetailsDelegate {
    func didCreateTask(_ taskEntity: TaskEntity) {
        presenter?.didCreateTask(taskEntity)
    }

    func didUpdateTask(_ taskEntity: TaskEntity) {
        presenter?.didUpdateTask(taskEntity)
    }
}
