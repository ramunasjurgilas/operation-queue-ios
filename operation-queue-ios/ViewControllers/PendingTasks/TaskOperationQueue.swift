//
//  TaskOperationQueue.swift
//  operation-queue-ios
//
//  Created by Ramunas Jurgilas on 2017-04-11.
//  Copyright © 2017 Ramūnas Jurgilas. All rights reserved.
//

import UIKit

class TaskOperationQueue: OperationQueue {

    func postponTask(_ task: Task) {
        operations.forEach() { [weak task] in
            if let taskOpertaion = $0 as? PendingTaskOperation,
                taskOpertaion.task == task {
                taskOpertaion.postpone()
            }
        }
    }
    
    func executeTask(_ task: Task) {
        for taskOperation in operations as! [PendingTaskOperation] {
            if taskOperation.task == task {
                taskOperation.resume()
                return
            }
        }
        let operation = PendingTaskOperation(pendingTask: task)
        addOperation(operation)
    }
}
