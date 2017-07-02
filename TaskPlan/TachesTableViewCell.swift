//
//  TachesTableViewCell.swift
//  TaskPlan
//
//  Created by Matthieu Turmo on 25/01/2017.
//  Copyright © 2017 Matthieu Turmo. All rights reserved.
//

import UIKit

class TachesTableViewCell: UITableViewCell {

    //MARK: Properties
    @IBOutlet weak var TitreTache: UILabel!
    @IBOutlet weak var urgenceIcon: UIImageView!
    @IBOutlet weak var dateTeche: UILabel!
    @IBOutlet weak var tempsRestantLabel: UILabel!
    
    var tacheDepassee:Int = 0
    var descriptionT:String = ""
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
