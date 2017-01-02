//
//  FirstView.swift
//  RainReminder
//
//  Created by 童超 on 16/4/11.
//  Copyright © 2016年 ChaosTong. All rights reserved.
//

import UIKit

class FirstView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadViewFormNib()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadViewFormNib()
        fatalError("init(coder:) has not been implemented")
    }
    
    func loadViewFormNib(){
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "FirstView", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        view.frame = bounds
        self.addSubview(view)
    }
    
    
}
