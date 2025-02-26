//
//  DummyJsonAPIAdapter.swift
//  ToDoList
//
//  Created by Kirill Pukhov on 21.02.2025.
//

import Foundation

class DummyJsonAPIAdapter: TasksAPIProtocol {
    private let client: DummyJsonAPIClient = .init()

    func fetchTasks(_ completionHandler: @escaping (Result<[TaskEntity], Error>) -> Void) {
        var description: String?
        if let descriptionURL = Bundle.main.url(forResource: "lorem-impsum-3p", withExtension: "txt") {
            description = try? String(contentsOf: descriptionURL, encoding: .utf8)
        }

        client.getToDos { result in
            switch result {
            case .success(let response):
                let entities = response.todos.map {
                    TaskEntity(
                        id: UUID(),
                        title: $0.todo,
                        description: description ?? "Lorem ipsum dolor sit amet, consectetur adipiscing elit.",
                        date: Date(),
                        isCompleted: $0.completed
                    )
                }

                DispatchQueue.main.async {
                    completionHandler(.success(entities))
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    completionHandler(.failure(error))
                }
            }
        }
    }
}
