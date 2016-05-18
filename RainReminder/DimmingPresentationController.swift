//
//  DimmingPresentationController.swift
//  RainReminder
//
//  Created by 童超 on 16/4/12.
//  Copyright © 2016年 ChaosTong. All rights reserved.
//

import UIKit

class DimmingPresentationController: UIPresentationController{
  override func shouldRemovePresentersView() -> Bool {
    return false
  }
  
  lazy var dimmingView = GradientView(frame: CGRect.zero)
  override func presentationTransitionWillBegin() {
    dimmingView.frame = containerView!.bounds
    containerView!.insertSubview(dimmingView, atIndex: 0)
  }
}
