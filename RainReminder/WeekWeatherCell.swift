//
//  WeekWeatherCell.swift
//  RainReminder
//
//  Created by 童超 on 16/4/11.
//  Copyright © 2016年 ChaosTong. All rights reserved.
//

import UIKit

class WeekWeatherCell: UICollectionViewCell {

    @IBOutlet weak var labelOfdate: UILabel!
    @IBOutlet weak var weatherIcon: UILabel!
    @IBOutlet weak var labelOftmpMin: UILabel!
    @IBOutlet weak var labelOftmpMax: UILabel!
    @IBOutlet weak var labelOfScheme: UILabel!
    @IBOutlet weak var labelOfpersent: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configureForDailyResult(_ dailyResult: DailyResult){
        
        labelOfdate.text = dailyResult.dailyDate
        labelOfScheme.text = dailyResult.dailyState
        labelOftmpMax.text = dailyResult.dailyTmpMax + " /"
        labelOftmpMin.text = dailyResult.dailyTmpMin
        labelOfpersent.text =
            "\(dailyResult.dailyPop)" + "%"
        let Icon = WeatherIcon(condition: dailyResult.dailyStateCode, iconString: "day").iconText
        weatherIcon.text = Icon
    }
    
}
