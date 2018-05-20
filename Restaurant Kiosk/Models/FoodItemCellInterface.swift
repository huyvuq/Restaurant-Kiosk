//
//  ItemCellInterface.swift
//  Restaurant Kiosk
//
//  Created by Huy Vu on 5/13/18.
//  Copyright © 2018 VietMyApps. All rights reserved.
//

import UIKit

protocol FoodItemCellInterface {
    
    static var id: String { get }
    static var cellNib: UINib { get }
    
}

extension FoodItemCellInterface {
    
    static var id: String {
        return String(describing: Self.self)
    }
    
    static var cellNib: UINib {
        return UINib(nibName: id, bundle: nil)
    }
    
}
