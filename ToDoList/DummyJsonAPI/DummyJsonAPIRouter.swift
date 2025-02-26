//
//  DummyJsonAPIRouter.swift
//  ToDoList
//
//  Created by Kirill Pukhov on 21.02.2025.
//

import Foundation
import Alamofire

enum DummyJsonAPIRouter: URLRequestConvertible {
    case getToDos

    var baseURL: URL { .init("https://dummyjson.com")! }

    var path: String {
        switch self {
        case .getToDos:
            return "/todos"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .getToDos:
            return .get
        }
    }

    func asURLRequest() throws -> URLRequest {
        let url = baseURL.appendingPathComponent(path)
        let request = try URLRequest(url: url, method: method)

        return request
    }
}
