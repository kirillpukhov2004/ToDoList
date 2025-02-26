//
//  GetToDosResponse.swift
//  ToDoList
//
//  Created by Kirill Pukhov on 21.02.2025.
//

import Foundation

struct GetToDosResponse: Decodable {
    var todos: [ToDo]

    struct ToDo: Decodable {
        var id: Int
        var todo: String
        var completed: Bool
    }
}
