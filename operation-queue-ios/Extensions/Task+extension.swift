//
//  Task+extension.swift
//  operation-queue-ios
//
//  Created by Ramunas Jurgilas on 2017-04-09.
//  Copyright © 2017 Ramūnas Jurgilas. All rights reserved.
//

import Foundation

enum TaskStatus: Int16 {
    case pending, executing, completed
    
    func text() -> String {
        switch self {
        case .pending: return "Pending"
        case .executing: return "Executing"
        case .completed: return "Completed"
        }
    }
}

extension Task {
    
    static func fill() {
        let context = CoreDataManager.shared.persistentContainer.viewContext
        for _ in 0...10 {
            let task = Task(context: context)
            task.status = TaskStatus.pending.rawValue
            task.iterations = 30000
        }
        try? context.save()
    }
    
    func iterationAsText() -> String? {
        return "\(currentIteration) of \(iterations)"
    }
    
    func statusAsText() -> String? {
        if let status = TaskStatus(rawValue: status) {
            return status.text()
        }
        return nil
    }
}
