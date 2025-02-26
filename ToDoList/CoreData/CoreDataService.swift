//
//  CoreDataService.swift
//  ToDoList
//
//  Created by Kirill Pukhov on 21.02.2025.
//

import Foundation
import CoreData

final class CoreDataService {
    static var shared: CoreDataService = .init()

    private let persistentContainer: NSPersistentContainer

    private lazy var privateManagedObjectContext: NSManagedObjectContext = {
        let managedObjectContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = persistentContainer.persistentStoreCoordinator
        return managedObjectContext
    }()

    lazy var managedObjectContext: NSManagedObjectContext = {
        let managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.parent = privateManagedObjectContext
        return managedObjectContext
    }()

    private init() {
        persistentContainer = NSPersistentContainer(name: "ToDoList")
        persistentContainer.loadPersistentStores { (storeDescription, error) in
            if let nsError = error as NSError? {
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

    func saveManagedObjectContext() {
        guard managedObjectContext.hasChanges || privateManagedObjectContext.hasChanges else { return }

        managedObjectContext.performAndWait {
            do {
                try managedObjectContext.save()
            } catch {
                let nsError = error as NSError
                print("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }

        privateManagedObjectContext.perform { [weak self] in
            do {
                try self?.privateManagedObjectContext.save()
            } catch {
                let nsError = error as NSError
                print("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

    func performBackgroundTask(_ closure: @escaping (NSManagedObjectContext) -> Void ) {
        let backgroundManagedObjectContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        backgroundManagedObjectContext.parent = managedObjectContext

        backgroundManagedObjectContext.perform {
            closure(backgroundManagedObjectContext)
        }
    }
}
