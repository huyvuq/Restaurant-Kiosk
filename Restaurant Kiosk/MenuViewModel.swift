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
    
    //Cart
    var cart : Variable<[CartCategory]> = Variable([])
    let cartDataSource = RxTableViewSectionedReloadDataSource<CartCategory>( configureCell: { (_, _, _, _) in fatalError()})
    //Order process
    var orderStatus : Variable<OrderStatus> = Variable(OrderStatus.processed)
    
    let foodItemDetailViewController = UIStoryboard(name: "Main", bundle:nil)
        .instantiateViewController(withIdentifier: "FoodItemDetail") as! FoodItemDetailViewController
    let receiptViewController = UIStoryboard(name: "Main", bundle:nil)
        .instantiateViewController(withIdentifier: "ReceiptView") as! ReceiptViewController

    init(){
        //Collection View (Food Item)
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
        
        //Side Table View (Order List)
        foodItemDetailViewController.viewModel.foodItemOder.asObservable().subscribe(onNext : {value in
            if !value.isEmpty() {
                if let i = self.cart.value.index(where: {$0.header == value.category_name}){
                    self.cart.value[i].items.append(value)
                } else {
                    self.cart.value.append(CartCategory(header: value.category_name, items: [value]))
                }
            }
        }).disposed(by: bag)
        
        
        cartDataSource.configureCell = {_, tableView, indexPath, item in
            let cell = tableView.dequeueReusableCell(withIdentifier: "CartCell", for: indexPath) as! CartCell
            cell.itemNameLabel.text = item.name
            cell.removeButton.rx.tap.subscribe(onNext: { _ in
                
                //TODO: Memory leaks here. fix later
                print("Section \(indexPath.section). Item: \(indexPath.item)")
                if self.cart.value[indexPath.section].items.indices.contains(indexPath.item){
                    self.cart.value[indexPath.section].items.remove(at: indexPath.item)
                }
            }).disposed(by: self.bag)

            return cell
        }
        
        cartDataSource.titleForHeaderInSection = {ds, index in
            return ds.sectionModels[index].header
        }
    }
    
    //MARK: Fetch Menu
    func fetchItemData()->(){
        let URL = serverURL?.appendingPathComponent("ItemUtils")
        RxAlamofire.requestJSON(.get, URL!).subscribe(onNext: { [weak self] (r, value) in
            let json = JSON(value)
            if json["status"]=="success"{
                let dict = try! JSONSerialization.jsonObject(with: json["item_list"].rawData(), options: [])
                let data = try! JSONSerialization.data(withJSONObject: dict, options: [])
                let items = try! JSONDecoder().decode([FoodItem].self, from: data)
                let dictionary = Dictionary(grouping: items, by: { $0.category_name})
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
    
    //MARK : - Request to place an order
    func placeOrder()->(){
        let URL = serverURL?.appendingPathComponent("PlaceOrder")
        let jsonData = try! JSONEncoder().encode(self.cart.value)
        let jsonItem = String(data: jsonData, encoding: String.Encoding.ascii)
        let parameters = ["json":jsonItem!] as [String:Any]
        self.orderStatus.value = OrderStatus.inOrder
        if self.cart.value.isEmpty {
            self.orderStatus.value = OrderStatus.processed
            print("Nothing to order")
            return
        }
        RxAlamofire.requestJSON(.post, URL!, parameters: parameters).subscribe(onNext: {(r, value) in
            let json = JSON(value)
            if json["status"]=="success"{
                print("success")
                self.cart.value.removeAll()
                self.orderStatus.value = OrderStatus.success
                
            }
            }, onError: { error in
                print(error)
                self.orderStatus.value = OrderStatus.failure
        }).disposed(by: bag)
    }
}

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

enum OrderStatus{
    case inOrder
    case success
    case failure
    case processed
}
