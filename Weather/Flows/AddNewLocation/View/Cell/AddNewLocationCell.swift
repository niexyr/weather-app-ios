//
//  AddNewLocationCell.swift
//  Weather
//
//  Created by Valery Shamshin on 03.06.2023.
//  Copyright © 2023 Heads and Hands. All rights reserved.
//

import UIKit

class AddNewLocationCell: UITableViewCell {
    
    @IBOutlet private weak var nameLabel: UILabel!

    func configure(with model: LocationModel) {
        nameLabel.text = model.locationFullName
    }
    
}
