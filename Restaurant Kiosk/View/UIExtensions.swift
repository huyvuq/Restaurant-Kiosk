//
//  UIExtensions.swift
//  Restaurant Kiosk
//
//  Created by Huy Vu on 5/17/18.
//  Copyright © 2018 VietMyApps. All rights reserved.
//

import Foundation
import UIKit


extension UIViewController {
    class func displaySpinner(onView : UIView) -> UIView {
        let spinnerView = UIView.init(frame: onView.bounds)
        spinnerView.backgroundColor = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
        let ai = UIActivityIndicatorView.init(activityIndicatorStyle: .whiteLarge)
        ai.startAnimating()
        ai.center = spinnerView.center
        
        DispatchQueue.main.async {
            spinnerView.addSubview(ai)
            onView.addSubview(spinnerView)
        }
        
        return spinnerView
    }
    
    class func removeSpinner(spinner :UIView) {
        DispatchQueue.main.async {
            spinner.removeFromSuperview()
        }
    }
}




extension FoodItemCollectionViewCell{
    func roundedCell(){
        self.contentView.layer.cornerRadius = 20.0
        self.contentView.layer.borderColor = UIColor.clear.cgColor
        
        self.contentView.layer.borderWidth = 1.0
        self.contentView.layer.masksToBounds = true
        
        self.layer.shadowOffset = CGSize(width: 2, height: 2)
        self.layer.shadowRadius = 3.5
        self.layer.shadowOpacity = 0.5
        self.layer.masksToBounds = false
        let newBounds = UIEdgeInsetsInsetRect(self.bounds, UIEdgeInsetsMake(10, 0, 0, 0))
        self.layer.shadowPath = UIBezierPath(roundedRect: newBounds, cornerRadius:self.contentView.layer.cornerRadius).cgPath
        
    }
}

extension UIView {
    
    func addShadow(){
        self.layer.shadowOpacity = 0.5
        self.layer.shadowOffset = CGSize(width: 2.0, height: 2.0)
        self.layer.shadowRadius = 3.5
    }
    
    func roundCorner(radius : CGFloat){
        self.layer.cornerRadius = radius
        //        self.layer.masksToBounds = true
    }
    
}

extension UIColor{
    static func transparentBlack() -> UIColor{
        return UIColor(red: 0, green: 0, blue: 0, alpha: 0.6)
    }
}
