//
//  CityListCell.swift
//  RainReminder
//
//  Created by 童超 on 16/4/11.
//  Copyright © 2016年 ChaosTong. All rights reserved.
//

import UIKit

class CityListCell: UITableViewCell {

    @IBOutlet weak var labelOfCity: UILabel!
    
    func addCityName(city: City){
        labelOfCity.text = city.cityCN
    }
    
}
