//
//  Topping.swift
//  Restaurant Kiosk
//
//  Created by Huy Vu on 5/18/18.
//  Copyright © 2018 VietMyApps. All rights reserved.
//

import Foundation
import RxDataSources

struct Topping {
    var name: String
    var quantity: Int
    init(name : String, quantity : Int) {
        self.name = name
        self.quantity = quantity
    }
    
    mutating func increase(){
       quantity += 1
    }
    
    mutating func decrease(){
        quantity = quantity > 0 ? quantity - 1 : 0
    }
    
    mutating func setQuantity(quantity : Int){
        self.quantity = quantity
    }
}

struct ToppingGroup {
    //    var header: String
    var items: [Item]
}
extension ToppingGroup: SectionModelType {
    typealias Item = Topping
    
    init(original: ToppingGroup, items: [Item]) {
        self = original
        self.items = items
    }
}


