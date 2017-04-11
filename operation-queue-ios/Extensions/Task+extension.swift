//
//  Task+extension.swift
//  operation-queue-ios
//
//  Created by Ramunas Jurgilas on 2017-04-09.
//  Copyright © 2017 Ramūnas Jurgilas. All rights reserved.
//

import Foundation

enum TaskStatus: Int16 {
    case pending, executing, completed, postponed
    
    func text() -> String {
        switch self {
        case .pending: return "Pending"
        case .executing: return "Executing"
        case .postponed: return "Posponed"
        case .completed: return "Completed"
        }
    }
}

extension Collection where Iterator.Element == TaskStatus {
    
    func predicate() -> NSPredicate? {
        let format = map() { "status = \($0.rawValue)" }.joined(separator: " OR ")
        return NSPredicate(format: format, argumentArray: nil)
    }
}


extension Task {
    
    static func fill() {
        let context = CoreDataManager.shared.persistentContainer.viewContext
        for i in 0...10 {
            let task = Task(context: context)
            task.status = TaskStatus.pending.rawValue
            task.name = "Task \(i)"
        }
        try? context.save()
    }    
    
    func statusAsText() -> String? {
        if let status = TaskStatus(rawValue: status) {
            return status.text()
        }
        return nil
    }
}
