//
//  TaskDetailsDelegate.swift
//  ToDoList
//
//  Created by Kirill Pukhov on 26.02.2025.
//

import Foundation

protocol TaskDetailsDelegate: AnyObject {
    func didCreateTask(_ taskEntity: TaskEntity)

    func didUpdateTask(_ taskEntity: TaskEntity)
}
