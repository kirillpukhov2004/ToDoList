//
//  TaskListCollectionViewCell.swift
//  ToDoList
//
//  Created by Kirill Pukhov on 21.02.2025.
//

import Foundation
import UIKit

struct TaskListContentConfiguration: UIContentConfiguration {
    let title: String
    let description: String
    let date: Date
    let isCompleted: Bool
    
    let checkmarkTapGestureAction: () -> Void

    func makeContentView() -> any UIView & UIContentView {
        return TaskListContentView(configuration: self)
    }

    func updated(for state: any UIConfigurationState) -> Self {
        return self
    }
}
