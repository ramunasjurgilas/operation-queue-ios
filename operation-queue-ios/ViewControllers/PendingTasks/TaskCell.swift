//
//  TaskCell.swift
//  operation-queue-ios
//
//  Created by Ramunas Jurgilas on 2017-04-09.
//  Copyright © 2017 Ramūnas Jurgilas. All rights reserved.
//

import UIKit

class TaskCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var iterationLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func configureWithTask(_ task: Task) {
        nameLabel.text = task.name
        iterationLabel.text = task.iterationAsText()
        statusLabel.text = task.statusAsText()
    }
}
