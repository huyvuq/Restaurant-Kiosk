//
//  ItemViewController.swift
//  Restaurant Kiosk
//
//  Created by Huy Vu on 5/13/18.
//  Copyright © 2018 VietMyApps. All rights reserved.
//

import UIKit
import Alamofire
import RxSwift
import RxCocoa
import RxAlamofire
import RxDataSources

class ItemViewController : UIViewController {
    
    //MARK: - Outlets
    @IBOutlet fileprivate weak var collectionView: UICollectionView!
    
    //MARK : - Properties
    
    let bag = DisposeBag()
    var categories : BehaviorRelay<[Category]> = BehaviorRelay(value: [])
    let dataSource = RxCollectionViewSectionedReloadDataSource<Category>( configureCell: { (_, _, _, _) in fatalError()})

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Register Cell Nib
        self.collectionView.register(FoodItemCollectionViewCell.cellNib, forCellWithReuseIdentifier:FoodItemCollectionViewCell.id)
        
        //Observables
        self.registerObservables()
        
        //CollectionView
        self.setCollectionView()
        collectionView.rx.setDelegate(self).disposed(by: bag)

        self.fetchItemData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

//MARK : - Reactive property registration
extension ItemViewController {
    func registerObservables(){
        categories.asObservable().subscribe(onNext: { items in
//            print (items.count)
        }).disposed(by: bag)
    }
}

//MARK : - Reactive Collection View
extension ItemViewController : UICollectionViewDelegateFlowLayout{
    func setCollectionView(){
        dataSource.configureCell = {_, collectionView, indexPath, item in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FoodItemCollectionViewCell", for: indexPath) as! FoodItemCollectionViewCell
            cell.foodItem.accept(item)
            return cell
        }
        
        dataSource.configureSupplementaryView = { dataSource, collectionView, kind, indexPath in
            let cell = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "Header", for: indexPath)  as! FoodHeader
            cell.titleLabel.text = dataSource.sectionModels[indexPath.section].header
            return cell
        }
        
        collectionView.rx.modelSelected(FoodItem.self).subscribe(onNext: { item in
            print(item)
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            let nextViewController = storyBoard.instantiateViewController(withIdentifier: "FoodItemDetail") as! FoodItemDetailViewController
            self.navigationController?.popToViewController(nextViewController, animated: true)
        }).disposed(by: bag)
        
        categories.asDriver().drive(collectionView.rx.items(dataSource: dataSource)).disposed(by: bag)
    }

    //Resize
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth = CGFloat(UIScreen.main.bounds.width/2 - 30.0)
        return CGSize(width: cellWidth, height: cellWidth)
    }
}

//MARK : - Fetch Data
extension ItemViewController {
    func fetchItemData()->(){
        let sv = UIViewController.displaySpinner(onView: self.view)
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
            
                UIViewController.removeSpinner(spinner: sv)
            }, onError: { error in
                UIViewController.removeSpinner(spinner: sv)
                    print(error)
            }).disposed(by: bag)
    }
}


