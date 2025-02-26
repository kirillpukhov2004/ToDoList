//
//  TaskEntity.swift
//  ToDoList
//
//  Created by Kirill Pukhov on 21.02.2025.
//

import Foundation

struct TaskEntity: Decodable {
    let id: UUID
    var title: String
    var description: String
    var date: Date
    var isCompleted: Bool

    static var placeholder: TaskEntity {
        .init(
            id: UUID(),
            title: "",
            description: "",
            date: .now,
            isCompleted: false
        )
    }
}

extension TaskEntity {
    init(taskManagedObject: Task) {
        self.id = taskManagedObject.id ?? UUID()
        self.title = taskManagedObject.title ?? ""
        self.description = taskManagedObject.descr ?? ""
        self.date = taskManagedObject.date ?? .now
        self.isCompleted = taskManagedObject.isCompleted
    }
}
