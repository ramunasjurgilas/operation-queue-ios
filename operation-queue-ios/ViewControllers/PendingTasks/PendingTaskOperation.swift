//
//  PendingTaskOperation.swift
//  operation-queue-ios
//
//  Created by Ramunas Jurgilas on 2017-04-11.
//  Copyright © 2017 Ramūnas Jurgilas. All rights reserved.
//

import UIKit

class PendingTaskOperation: Operation {
    var count = 0
    let task: Task
    var executionStart = Date()
    var currentIteration = 0
    var timer: Timer?
    
    init(pendingTask: Task) {
        task = pendingTask
        super.init()
    }
    
    override func start() {
        executionStart = Date()
        task.status = TaskStatus.executing.rawValue
        try? task.managedObjectContext?.save()
        isExecuting = true
        isFinished = false
        main()
    }
    
    override func main() {
        print("start on:  -> " + Date().debugDescription)
        for i in currentIteration...10 {
            DispatchQueue.main.async { [weak self] in
                self?.task.duration = Int32((self?.executionStart.timeIntervalSinceNow)!) * -1
            }
            currentIteration = i
            print("Iteration: \(currentIteration)")
            if isExecuting == false {
                // count = i
                print("Is executing: \(i.description) " + isExecuting.description)
                // isFinished = true
                return
            }
            sleep(1)
        }
        DispatchQueue.main.async { [weak self] in
            self?.task.status = TaskStatus.completed.rawValue
            self?.task.duration = Int32((self?.executionStart.timeIntervalSinceNow)!) * -1
            try? self?.task.managedObjectContext?.save()
        }
        print("end " + Date().debugDescription)
        isFinished = true
    }
    
    func postpone() {
        timer?.invalidate()
        task.status = TaskStatus.postponed.rawValue
        print("Post pone: \(currentIteration)")
        isExecuting = false
        isFinished = false
        timer = Timer.scheduledTimer(timeInterval: 4, target: self, selector: #selector(resume), userInfo: nil, repeats: false)
    }
    
    func resume() {
        if task.status != TaskStatus.postponed.rawValue {
            print("Task is not postponed. Can not resume.")
        }
        timer?.invalidate()
        print("resume operaiton")
        DispatchQueue.main.async { [weak self] in
            self?.task.status = TaskStatus.executing.rawValue
            try? self?.task.managedObjectContext?.save()
        }
        DispatchQueue.global(qos: .default).async { [weak self] in
            self?.isExecuting = true
            self?.isFinished = false
            self?.main()
        }
    }
    
    fileprivate var _executing: Bool = false
    override var isExecuting: Bool {
        get {
            return _executing
        }
        set {
            if _executing != newValue {
                willChangeValue(forKey: "isExecuting")
                _executing = newValue
                didChangeValue(forKey: "isExecuting")
            }
        }
    }
    
    fileprivate var _finished: Bool = false;
    override var isFinished: Bool {
        get {
            return _finished
        }
        set {
            if _finished != newValue {
                willChangeValue(forKey: "isFinished")
                _finished = newValue
                didChangeValue(forKey: "isFinished")
            }
        }
    }
}
