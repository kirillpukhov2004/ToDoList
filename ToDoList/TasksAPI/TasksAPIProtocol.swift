//
//  TasksAPIProtocol.swift
//  ToDoList
//
//  Created by Kirill Pukhov on 21.02.2025.
//

import Foundation

protocol TasksAPIProtocol: AnyObject {
    func fetchTasks(_ completionHandler: @escaping (Result<[TaskEntity], Error>) -> Void)
}
