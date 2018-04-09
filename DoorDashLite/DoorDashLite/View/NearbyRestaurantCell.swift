//
//  NearbyRestaurantCell.swift
//  DoorDashLite
//
//  Created by Vikramjeet Singh on 4/7/18.
//  Copyright © 2018 Vikramjeet Singh. All rights reserved.
//

import UIKit

protocol ConfigurableCell {
    associatedtype ViewModel
    
    func configure(at: IndexPath, with viewModel: ViewModel)
}

final class NearbyRestaurantCell: UITableViewCell {

    // MARK: - IBOutlets
    @IBOutlet weak private var thumbnail: UIImageView! {
        didSet {
            thumbnail.layer.cornerRadius = 5.0
            thumbnail.layer.masksToBounds = true
        }
    }
    
    @IBOutlet weak private var name: UILabel!
    @IBOutlet weak private var type: UILabel!
    @IBOutlet weak private var deliveryCost: UILabel!
    @IBOutlet weak private var wait: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
}

extension NearbyRestaurantCell: ConfigurableCell {
    
    func configure(at indexPath: IndexPath, with viewModel: ExploreViewModel) {
        name.text = viewModel.name(at: indexPath.row)
        type.text = viewModel.type(at: indexPath.row)
        deliveryCost.text = viewModel.deliveryFee(at: indexPath.row)
        wait.text = viewModel.waitStatus(at: indexPath.row)
        thumbnail.image = nil
        viewModel.getImage(for: indexPath) { image in
            DispatchQueue.main.async {
                self.thumbnail.image = image
            }
        }
    }
}
