//
//  InteractiveAnimation.swift
//  UmbrellaWeather
//
//  Created by ZeroJianMBP on 16/1/24.
//  Copyright © 2016年 ZeroJian. All rights reserved.
//

import UIKit

typealias animationFinshion = (Bool) -> Void

  
  func springAnimation1(_ currtntView: UIView){
    currtntView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
    UIView.animate(withDuration: 0.3, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.0, options: [], animations: { () -> Void in
      currtntView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
      }, completion: nil)
  }
  
  func animationWithColor(_ superView: UIView,color: UIColor){
    UIView.transition(with: superView, duration: 1.0, options: UIViewAnimationOptions.transitionCrossDissolve, animations: { () -> Void in
      superView.backgroundColor = color
      }, completion: nil)
  }
  
  func loadingAnimation(_ imageView: UIImageView){
    if imageView.isHidden{
      imageView.isHidden = false
    }
    rotationAnimated(imageView)
  }
  
  private func rotationAnimated(_ imageView: UIImageView){
    let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
    rotationAnimation.toValue = NSNumber(value: M_PI * 2.0 as Double)
    rotationAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
    rotationAnimation.duration = 0.3
    rotationAnimation.repeatCount = MAXFLOAT
    rotationAnimation.isCumulative = false
    rotationAnimation.isRemovedOnCompletion = false
    rotationAnimation.fillMode = kCAFillModeForwards
    imageView.layer.add(rotationAnimation, forKey: "Rotation")
  }
  
  func launchAnimation(_ currentView: UIView,finishion: @escaping animationFinshion){
    var animationDone = false
    let launchView = UIImageView(frame: currentView.bounds)
    //launchView.imageWithResolution()
    currentView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
    launchView.transform = CGAffineTransform(scaleX: 1.25, y: 1.25)
    currentView.addSubview(launchView)
    //启动图片扩大消失动画
    UIView.animate(withDuration: 0.3, delay: 0.9, options: [], animations: {
      launchView.transform = CGAffineTransform(scaleX: 2.0, y: 2.0)
      launchView.alpha = 0.0
      }) { (_) in
        launchView.removeFromSuperview()
    }
    //主视图扩大弹跳动画
    UIView.animate(withDuration: 0.3, delay: 1.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1.0, options: [], animations: { () -> Void in
      currentView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
      }){ (_) in
      animationDone = true
      finishion(animationDone)
    }
  }

