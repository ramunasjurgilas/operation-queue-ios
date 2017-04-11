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
    var thread: Thread?
    
    deinit {
        print("Deinit")
    }
    
     init(pendingTask: Task) {
        task = pendingTask
        super.init()
    }
    
    override func start() {
        thread = Thread.current
        executionStart = Date()
        print("Start TASK ")
        task.status = TaskStatus.executing.rawValue
        try? task.managedObjectContext?.save()
        isExecuting = true
        isFinished = false
        main()
    }
    
    override func main() {
        print("start on thread:  -> \(Thread.current.debugDescription) ->" + Date().debugDescription)
        for i in currentIteration...10 {
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
        task.status = TaskStatus.completed.rawValue
        task.duration = Int32(executionStart.timeIntervalSinceNow) * -1
        try? task.managedObjectContext?.save()
        
        print("end " + Date().debugDescription)
        isFinished = true
    }
    
    func postpone() {
        timer?.invalidate()
        task.status = TaskStatus.postponed.rawValue
        print("Post pone: \(currentIteration) -> \(Thread.current.debugDescription)")
        isExecuting = false
        isFinished = false
        timer = Timer.scheduledTimer(timeInterval: 4, target: self, selector: #selector(resume), userInfo: nil, repeats: false)
    }
    
    func resume() {
        if task.status != TaskStatus.postponed.rawValue {
            print("Task is not postponed. Can not resume.")
        }
        timer?.invalidate()
        print("resume operaiton \(Thread.current.debugDescription)")
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
