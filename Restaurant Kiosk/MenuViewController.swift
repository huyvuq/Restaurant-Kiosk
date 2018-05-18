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

class MenuViewController : UIViewController {
    
    //MARK: - Outlets
    @IBOutlet fileprivate weak var collectionView: UICollectionView!
    
    //MARK : - Properties
    var viewModel = MenuViewModel()//
    let bag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Register Cell Nib
        self.collectionView.register(FoodItemCollectionViewCell.cellNib, forCellWithReuseIdentifier:FoodItemCollectionViewCell.id)
        
        
        //CollectionView
        collectionView.rx.modelSelected(FoodItem.self).subscribe(onNext: { item in
            self.viewModel.foodItemDetailViewController.viewModel.foodItem.accept(item)
            self.navigationController?.present(self.viewModel.foodItemDetailViewController, animated: true)
        }).disposed(by: bag)
        
        self.viewModel.categories.asDriver().drive(collectionView.rx.items(dataSource: self.viewModel.dataSource)).disposed(by: bag)
        collectionView.rx.setDelegate(self).disposed(by: bag)

        //Retrieve Data
        self.viewModel.fetchItemData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

//MARK : - Reactive Collection View
extension MenuViewController : UICollectionViewDelegateFlowLayout{
    //Resize
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth = CGFloat(UIScreen.main.bounds.width/2 - 30.0)
        return CGSize(width: cellWidth, height: cellWidth)
    }
}


