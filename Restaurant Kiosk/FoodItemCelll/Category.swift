//
//  Category.swift
//  Restaurant Kiosk
//
//  Created by Huy Vu on 5/17/18.
//  Copyright © 2018 VietMyApps. All rights reserved.
//

import Foundation
import RxDataSources

struct Category {
    var header: String
    var items: [Item]
}

extension Category: SectionModelType {
    typealias Item = FoodItem
    
    init(original: Category, items: [Item]){
        self = original
        self.items = items
    }
}
