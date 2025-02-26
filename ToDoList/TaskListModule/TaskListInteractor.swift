//
//  TaskListInteractor.swift
//  ToDoList
//
//  Created by Kirill Pukhov on 21.02.2025.
//

import CoreData
import Foundation

protocol TaskListInteractorInputProtocol: AnyObject {
    var numberOfTasks: Int { get }
    var numberOfUncompletedTasks: Int { get }

    func viewWillAppear()
    func viewWillDisappear()

    func getTask(for indexPath: IndexPath) -> TaskEntity
    func deleteTask(at indexPath: IndexPath)
    func toggleTaskCompletion(at indexPath: IndexPath)
}

protocol TaskListInteractorOutputProtocol: AnyObject {
    func didFetchTasks()
    func didInsertTask(at indexPath: IndexPath)
    func didUpdateTask(at indexPath: IndexPath)
    func didDeleteTask(at indexPath: IndexPath)

    func willStartInitialFetch()
    func didFinishInitialFetch()
}

final class TaskListInteractor: NSObject, TaskListInteractorInputProtocol {
    weak var presenter: TaskListInteractorOutputProtocol?

    private let coreDataService: CoreDataService
    private let tasksAPI: TasksAPIProtocol

    private var fetchedResultsController: NSFetchedResultsController<Task>?

    var numberOfTasks: Int {
        fetchedResultsController?.fetchedObjects?.count ?? 0
    }

    var numberOfUncompletedTasks: Int {
        let fetchRequest = Task.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "isCompleted = 0")

        do {
            return try coreDataService.managedObjectContext.count(for: fetchRequest)
        } catch {
            let nsError = error as NSError
            print("Unresolved error: \(nsError), \(nsError.userInfo)")

            return 0
        }
    }

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

        super.init()
    }

    func viewWillAppear() {
        let fetchRequest = Task.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]

        fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: coreDataService.managedObjectContext,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        fetchedResultsController?.delegate = self

        fetchTasks()
    }

    func viewWillDisappear() {
        fetchedResultsController = nil
    }

    func getTask(for indexPath: IndexPath) -> TaskEntity {
        guard let taskManagedObject = fetchedResultsController?.object(at: indexPath) else  { return .placeholder }

        return TaskEntity(taskManagedObject: taskManagedObject)
    }

    func fetchTasks() {
        guard let fetchedResultsController else { return }

        do {
            try fetchedResultsController.performFetch()
            presenter?.didFetchTasks()

            if !isInitialFetchCompleted { initialFetchTasks() }
        } catch {
            let nsError = error as NSError
            print("Unresolved error: \(nsError), \(nsError.userInfo)")
        }
    }

    func toggleTaskCompletion(at indexPath: IndexPath) {
        guard let taskManagedObject = fetchedResultsController?.object(at: indexPath) else  { return }

        taskManagedObject.isCompleted.toggle()
        coreDataService.saveManagedObjectContext()
    }

    func deleteTask(at indexPath: IndexPath) {
        guard let taskManagedObject = fetchedResultsController?.object(at: indexPath) else  { return }

        coreDataService.managedObjectContext.delete(taskManagedObject)
        coreDataService.saveManagedObjectContext()
    }

    private func initialFetchTasks() {
        presenter?.willStartInitialFetch()

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

                coreDataService.saveManagedObjectContext()
            case .failure(let error):
                let nsError = error as NSError
                print("Unresolved error: \(nsError), \(nsError.userInfo)")
            }

            isInitialFetchCompleted = true
            presenter?.didFinishInitialFetch()
        }
    }
}

extension TaskListInteractor: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<any NSFetchRequestResult>) {
        presenter?.didFetchTasks()
    }

    func controller(
        _ controller: NSFetchedResultsController<any NSFetchRequestResult>,
        didChange anObject: Any,
        at indexPath: IndexPath?,
        for type: NSFetchedResultsChangeType,
        newIndexPath: IndexPath?
    ) {
//        switch type {
//        case .insert:
//            if let newIndexPath {
//                presenter?.didInsertTask(at: newIndexPath)
//            }
//        case .delete:
//            if let indexPath {
//                presenter?.didDeleteTask(at: indexPath)
//            }
//        case .move:
//            break
//        case .update:
//            if let indexPath {
//                presenter?.didUpdateTask(at: indexPath)
//            }
//        default:
//            break
//        }
    }
}
