//
//  APIManager.swift
//  Restaurant Kiosk
//
//  Created by Huy Vu on 5/15/18.
//  Copyright © 2018 VietMyApps. All rights reserved.
//

import Foundation
import Alamofire
import RxSwift
import RxCocoa
import RxAlamofire

class APIManager : NSObject{
    
    static func fetchFoodItems(completion: @escaping ([Category]?) -> ()){
        let URL = serverURL?.appendingPathComponent("ItemUtils")
        let bag = DisposeBag()
        var cat : [Category] = []
        let queue = DispatchQueue(label: "com.test.api", qos: .background, attributes: .concurrent)
        RxAlamofire.requestJSON(.get, URL!).subscribe(onNext: {(r, value) in
            let json = JSON(value)
            if json["status"]=="success"{
                let dict = try! JSONSerialization.jsonObject(with: json["item_list"].rawData(), options: [])
                let data = try! JSONSerialization.data(withJSONObject: dict, options: [])
                let items = try! JSONDecoder().decode([FoodItem].self, from: data)
                
                let dictionary = Dictionary(grouping: items, by: { $0.category_name!})
                for (key, value) in dictionary {
                    cat.append(Category(header: key, items: value))
                }
                completion(cat)
                print(json)
            }
        }, onError: { error in
            print("There was an error: \(error)")
            completion(nil)
        }).disposed(by: bag)
    }
    
    
}

//        Alamofire.request(URL!, method: .get).responseJSON { response in
//            switch response.result {
//            case .success(let value):
//                let json = JSON(value)
//
//                let data = try! JSONSerialization.data(withJSONObject: json["item_list"].array![0].dictionaryObject! as [String: Any], options: [])
//                let model = try! JSONDecoder().decode(Item.self, from: data)
//                print(model.name)
//            case .failure:
//                print(response)
//            }
//        }
