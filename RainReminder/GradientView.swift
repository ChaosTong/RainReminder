//
//  GradientView.swift
//  RainReminder
//
//  Created by 童超 on 16/4/12.
//  Copyright © 2016年 ChaosTong. All rights reserved.
//

import UIKit

class GradientView: UIView{
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    backgroundColor = UIColor.clear
  }

  required init?(coder aDecoder: NSCoder) {
      super.init(coder: aDecoder)
    backgroundColor = UIColor.clear
  }
}
