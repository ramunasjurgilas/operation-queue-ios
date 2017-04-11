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
    
    deinit {
        print("Deinit")
    }
    
     init(pendingTask: Task) {
        task = pendingTask
        super.init()
    }
    
    override func start() {
        isExecuting = true
        isFinished = false
        main()
    }
    
    override func main() {
        print("start " + Date().debugDescription)
        for i in task.currentIteration...30000 {
            task.currentIteration = 1
            if isExecuting == false {
               // count = i
                print("Is executing: \(i.description) " + isExecuting.description)
               // isFinished = true
                return
            }
            //    print("Is executing: " + isExecuting.description)
            if isCancelled {
                print("was canceld" + isFinished.description)
                break
            }
            // print(i.description)
            var j = Float(i) * 3.3323
            j += 1.4
        }
        print("end " + Date().debugDescription)
        isFinished = true
    }
    
    func postpone() {
        print("Post pone: "/* + (queue?.operationCount ?? -1)*/)
        isExecuting = false
        isFinished = false
        
        Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { [weak self] (timer) in
            print("Start once again: " + Date().debugDescription)
            self?.isExecuting = true
            self?.isFinished = false
            self?.main()
        }
    }
    
    func resume() {
        print("resume operaiton")
    }
    
    fileprivate var _executing: Bool = false
    override var isExecuting: Bool {
        get {
            return _executing
        }
        set {
            print("exe: " + _executing.description)
            if _executing != newValue {
                willChangeValue(forKey: "isExecuting")
                _executing = newValue
                didChangeValue(forKey: "isExecuting")
                print("exe: " + self.description)
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
