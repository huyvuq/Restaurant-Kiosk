//
//  CartCategory.swift
//  Restaurant Kiosk
//
//  Created by Huy Vu on 5/20/18.
//  Copyright © 2018 VietMyApps. All rights reserved.
//

import Foundation
import RxDataSources


struct CartCategory : Codable{
    var header: String
    var items: [Item]
}

extension CartCategory: SectionModelType {
    typealias Item = FoodItemOrder
    
    init(original: CartCategory, items: [Item]){
        self = original
        self.items = items
    }
}
