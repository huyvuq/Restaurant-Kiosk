//
//  Item.swift
//  Restaurant Kiosk
//
//  Created by Huy Vu on 5/13/18.
//  Copyright © 2018 VietMyApps. All rights reserved.
//

import Foundation
import RxDataSources

protocol Item {
    var id : String { get set }
    var name : String { get set }
    var category_name : String { get set }
}

struct FoodItem : Item, Codable{
    var id : String = ""
    var name : String = ""
    var description : String = ""
    var img_url : String?
    var ingredient_array : [String]? //aka topping (backend defined as ingredient_array)
    var category_name : String = ""
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(String.self, forKey: .id)
        name = try values.decode(String.self, forKey: .name)
        description = try values.decodeIfPresent(String.self, forKey: .description) ?? ""
        img_url = try? values.decodeIfPresent(String.self, forKey: .img_url) ?? ""
        ingredient_array = try? values.decodeIfPresent([String].self, forKey: .ingredient_array) ?? []
        category_name = try values.decodeIfPresent(String.self, forKey: .category_name) ?? ""
    }
    
    init(){
    }
}

struct FoodItemOrder : Item, Codable {
    var id : String = ""
    var name : String = ""
    var topping : [String:Int] = [:]
    var category_name : String = ""
    
    func isEmpty() -> Bool {
        return id.isEmpty
    }
}
