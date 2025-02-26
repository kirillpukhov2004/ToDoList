//
//  DummyJsonAPIClient.swift
//  ToDoList
//
//  Created by Kirill Pukhov on 21.02.2025.
//

import Foundation
import Alamofire

class DummyJsonAPIClient {
    func getToDos(_ completionHandler: @escaping (Result<GetToDosResponse, Error>) -> Void) {
        let request = AF.request(DummyJsonAPIRouter.getToDos)
        request.responseDecodable(of: GetToDosResponse.self) { response in
            switch response.result {
            case .success(let value):
                completionHandler(.success(value))
            case .failure(let error):
                completionHandler(.failure(error))
            }
        }
    }
}
