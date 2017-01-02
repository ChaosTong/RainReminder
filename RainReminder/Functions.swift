//
//  Functions.swift
//  RainReminder
//
//  Created by 童超 on 16/4/6.
//  Copyright © 2016年 ChaosTong. All rights reserved.
//

import Foundation
import Dispatch

func afterDelay(_ seconds: Double, closure: @escaping () -> ()) {
    let when =  DispatchTime.now() + Double(Int64(seconds * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
    DispatchQueue.main.asyncAfter(deadline: when, execute: closure)
}

