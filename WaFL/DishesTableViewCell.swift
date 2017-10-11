//
//  DishesTableViewCell.swift
//  Kanna_Attempt_1
//
//  Created by Sahitya Mohan Lal on 07/08/2017.
//  Copyright © 2017 Sahitya Mohan Lal. All rights reserved.
//

import UIKit

class DishesTableViewCell: UITableViewCell {

    @IBOutlet weak var pricesLabel: UILabel!
    @IBOutlet weak var dishesLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        dishesLabel.font = UIFont(name: "Steiner", size: 13)
        pricesLabel.font = UIFont(name: "Steiner", size: 13)
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
