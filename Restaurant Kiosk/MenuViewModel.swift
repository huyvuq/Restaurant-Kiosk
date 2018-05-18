//
//  MenuViewModel.swift
//  Restaurant Kiosk
//
//  Created by Huy Vu on 5/18/18.
//  Copyright © 2018 VietMyApps. All rights reserved.
//

import Foundation
import Alamofire
import RxSwift
import RxCocoa
import RxAlamofire
import RxDataSources

class MenuViewModel{
    //MARK: Properties
    var categories : BehaviorRelay<[Category]> = BehaviorRelay(value: [])
    let dataSource = RxCollectionViewSectionedReloadDataSource<Category>( configureCell: { (_, _, _, _) in fatalError()})
    let bag = DisposeBag()
    var foodItemOrder = [FoodItemOrder]()
    
    let foodItemDetailViewController = UIStoryboard(name: "Main", bundle:nil)
        .instantiateViewController(withIdentifier: "FoodItemDetail") as! FoodItemDetailViewController


    init(){
        dataSource.configureCell = {_, collectionView, indexPath, item in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FoodItemCollectionViewCell", for: indexPath) as! FoodItemCollectionViewCell
            cell.foodItemmViewModel.foodItem.accept(item)
            return cell
        }
        
        dataSource.configureSupplementaryView = { dataSource, collectionView, kind, indexPath in
            let cell = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "Header", for: indexPath)  as! FoodHeader
            cell.titleLabel.text = dataSource.sectionModels[indexPath.section].header
            return cell
        }
        
        foodItemDetailViewController.viewModel.foodItemOder.asObservable().subscribe(onNext : {value in
            if !value.isEmpty() {
                self.foodItemOrder.append(value)
                print(value)
            }
        }).disposed(by: bag)
    }
    
    func fetchItemData()->(){
        let URL = serverURL?.appendingPathComponent("ItemUtils")
        
        RxAlamofire.requestJSON(.get, URL!).subscribe(onNext: { [weak self] (r, value) in
            let json = JSON(value)
            if json["status"]=="success"{
                let dict = try! JSONSerialization.jsonObject(with: json["item_list"].rawData(), options: [])
                let data = try! JSONSerialization.data(withJSONObject: dict, options: [])
                let items = try! JSONDecoder().decode([FoodItem].self, from: data)
                let dictionary = Dictionary(grouping: items, by: { $0.category_name!})
                var cat : [Category] = []
                for (key, value) in dictionary {
                    cat.append(Category(header: key, items: value))
                }
                
                self!.categories.accept(cat)
            }
            }, onError: { error in
                print(error)
        }).disposed(by: bag)
    }
}
