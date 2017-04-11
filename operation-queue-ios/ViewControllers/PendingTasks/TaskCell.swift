//
//  TaskCell.swift
//  operation-queue-ios
//
//  Created by Ramunas Jurgilas on 2017-04-09.
//  Copyright © 2017 Ramūnas Jurgilas. All rights reserved.
//

import UIKit

protocol TaskCellDelegate {
    func didSwipeLeft(_ task: Task)
    func didSwipeRight(_ task: Task)
}

class TaskCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var iterationLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    
    var delegate: TaskCellDelegate?
    weak var task: Task!

    func configureWithTask(_ task: Task, delegate: TaskCellDelegate) {
        self.delegate = delegate
        self.task = task
        nameLabel.text = task.name
        iterationLabel.text = task.iterationAsText()
        statusLabel.text = task.statusAsText()
        
        let leftGesture = UISwipeGestureRecognizer(target: self, action: #selector(didSwipeLeft))
        leftGesture.direction = .left
        addGestureRecognizer(leftGesture)
        removeGestureRecognizer(leftGesture)
        let rightGesture = UISwipeGestureRecognizer(target: self, action: #selector(didSwipeRight))
        rightGesture.direction = .right
        addGestureRecognizer(rightGesture)
    }
    
    func didSwipeLeft(_ sender: AnyObject) {
        delegate?.didSwipeLeft(task)
    }
    
    func didSwipeRight(_ sender: AnyObject) {
        delegate?.didSwipeRight(task)
    }
}
