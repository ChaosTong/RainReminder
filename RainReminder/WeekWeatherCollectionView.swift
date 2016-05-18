//
//  WeekWeatherCollectionView.swift
//  RainReminder
//
//  Created by 童超 on 16/4/11.
//  Copyright © 2016年 ChaosTong. All rights reserved.
//

import UIKit

class WeekWeatherCollectionView: UICollectionView {

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        let cellNib = UINib(nibName: "WeekWeatherCell", bundle: nil)
        self.registerNib(cellNib, forCellWithReuseIdentifier: "WeekWeatherCell")
    }

}
