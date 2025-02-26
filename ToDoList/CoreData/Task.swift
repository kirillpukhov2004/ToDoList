//
//  Task.swift
//  ToDoList
//
//  Created by Kirill Pukhov on 21.02.2025.
//

import Foundation
import CoreData

@objc(Task)
final class Task: NSManagedObject {
    override func awakeFromInsert() {
        super.awakeFromInsert()

        id = UUID()
        title = ""
        descr = ""
        date = Date()
        isCompleted = false
    }
}
