//
//  FoodItemDetailViewModel.swift
//  Restaurant Kiosk
//
//  Created by Huy Vu on 5/18/18.
//  Copyright © 2018 VietMyApps. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxDataSources
import AlamofireImage

class FoodItemDetailViewModel {
    var foodItem : BehaviorRelay<FoodItem> = BehaviorRelay(value: FoodItem())
    var toppingGroups : BehaviorRelay<[ToppingGroup]> = BehaviorRelay(value: [])
    var image : BehaviorRelay<UIImage> = BehaviorRelay(value: UIImage())
    let disposeBag = DisposeBag()
    
    //Food Item Order properties
    var foodItemOder : BehaviorRelay<FoodItemOrder> = BehaviorRelay(value: FoodItemOrder())
    var toppingGroupOrder : [ToppingGroup] = []

    //Table view data
    let dataSource = RxTableViewSectionedReloadDataSource<ToppingGroup>( configureCell: { (_, _, _, _) in fatalError()})
    
    init(){
        foodItem.asObservable().subscribe(onNext : { value in
            //Image
            if let imageURL = value.img_url {
                if (!imageURL.isEmpty){
                    let imageCache = AutoPurgingImageCache()
                    let imageCacheName = "\(imageURL)"
                    let imageCacheURL =  URLRequest(url: URL(string: "\(imageURL)")!)
                    let fileUrl = NSURL(string:  "\(imageURL)")
                    
                    let uiImageView = UIImageView()
                    uiImageView.af_setImage(withURL: fileUrl! as URL,
                                            placeholderImage: nil,
                                            completion: { response in
                                                if response.result.isSuccess {
                                                    imageCache.add(response.result.value!, for: imageCacheURL, withIdentifier: imageCacheName)
                                                    self.image.accept(response.result.value!)
                                                }
                    })
                }
            }
            
        }).disposed(by: disposeBag)
        
        //Table view
        dataSource.configureCell = {_, tableView, indexPath, item in
            let cell = tableView.dequeueReusableCell(withIdentifier: "ToppingCell", for: indexPath) as! ToppingTableViewCell
            cell.toppingItem.value = item
            cell.toppingItem.asObservable().subscribe(onNext : { value in
                self.toppingGroupOrder[0].items[indexPath.item] = value
            }).disposed(by: self.disposeBag)
            return cell
        }
    }
}

//MARK - Get topping
extension FoodItemDetailViewModel{
    func getToppings() -> [String:Int] {
        if (self.toppingGroupOrder.count > 0){
            let toppings = toppingGroupOrder[0].items.reduce(into: [String: Int]()) {
                $0[$1.name] = $1.quantity
            }
            return toppings
        }
        return [:]
    }
}
