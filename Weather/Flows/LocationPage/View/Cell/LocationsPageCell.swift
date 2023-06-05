//
//  LocationsPageCell.swift
//  Weather
//
//  Created by Valery Shamshin on 03.06.2023.
//  Copyright © 2023 Heads and Hands. All rights reserved.
//

import UIKit
import Kingfisher

class LocationsPageCell: UICollectionViewCell {
    
    @IBOutlet private weak var locationNameLabel: UILabel!
    @IBOutlet private weak var temperatureLabel: UILabel!
    @IBOutlet private weak var weatherIconView: UIImageView!
    @IBOutlet private weak var weatherDescriptionLabel: UILabel!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        weatherIconView.kf.cancelDownloadTask()
    }
    
    func configure(
        location: LocationModel,
        temperature: Double?,
        iconUrl: URL?,
        weatherDescription: String?
    ) {
        locationNameLabel.text = location.locationFullName
        temperatureLabel.text = temperature?.asTemperatureString ?? ""
        
        weatherIconView.alpha = 0.25
        weatherIconView.kf.setImage(with: iconUrl)
        
        weatherDescriptionLabel.isHidden = weatherDescription.isNilOrEmpty
        weatherDescriptionLabel.text = weatherDescription?.capitalizingFirstLetter()
    }
    
}
