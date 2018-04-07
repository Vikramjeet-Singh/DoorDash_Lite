//
//  NearbyRestaurantCell.swift
//  DoorDashLite
//
//  Created by Vikramjeet Singh on 4/7/18.
//  Copyright © 2018 Vikramjeet Singh. All rights reserved.
//

import UIKit

final class NearbyRestaurantCell: UITableViewCell {

    // MARK: - IBOutlets
    @IBOutlet weak private var thumbnail: UIImageView!
    @IBOutlet weak private var nameLabel: UILabel!
    @IBOutlet weak private var typeLabel: UILabel!
    @IBOutlet weak private var deliveryCostLabel: UILabel!
    @IBOutlet weak private var waitLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // TODO: Make configure method generic. Think if protocol or generic function or extension to uitableview

}
