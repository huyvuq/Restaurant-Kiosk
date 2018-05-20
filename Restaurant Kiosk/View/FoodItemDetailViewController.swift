//
//  FoodItemDetailViewController.swift
//  Restaurant Kiosk
//
//  Created by Huy Vu on 5/17/18.
//  Copyright © 2018 VietMyApps. All rights reserved.
//

import UIKit
import AlamofireImage
import RxSwift
import RxCocoa
import RxDataSources

class FoodItemDetailViewController: UIViewController {
    //MARK : Properties
    var viewModel = FoodItemDetailViewModel()
    let disposeBag = DisposeBag()
    
//    //Table view data
//    let dataSource = RxTableViewSectionedReloadDataSource<ToppingGroup>( configureCell: { (_, _, _, _) in fatalError()})

    //MARK : - Outlets
    @IBOutlet weak var foodImageView: UIImageView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet var addButtonOutlet: UIButton!
    @IBOutlet var cancelButtonOutlet: UIButton!
    @IBOutlet var toppingTableView: UITableView!
    @IBOutlet weak var nameAndDescriptionLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //UI Effects
        self.setUIComponentEffects()

        //Model view bind
        self.viewModelBinding()
        
        //Button Binding
        addButtonOutlet.rx.tap.bind(onNext: {
            self.viewModel.foodItemOder.accept(FoodItemOrder(id: self.viewModel.foodItem.value.id,
                                                             name: self.viewModel.foodItem.value.name,
                                                             topping: self.viewModel.getToppings(),
                                                             category_name: self.viewModel.foodItem.value.category_name))
            self.dismiss(animated: true, completion: nil)
        }).disposed(by: disposeBag)
        
        cancelButtonOutlet.rx.tap.bind(onNext: {
            self.dismiss(animated: true, completion: nil)

        }).disposed(by: disposeBag)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.viewModel.toppingGroupOrder.removeAll()
    }
    
}

extension FoodItemDetailViewController {
    //MARK : - UI component effcts
    func setUIComponentEffects(){
        self.addButtonOutlet.addShadow()
        self.cancelButtonOutlet.addShadow()
        self.containerView.roundCorner(radius: 10)
        self.containerView.addShadow()
    }
    
    func viewModelBinding(){
        //Reactive : binding on change
        self.viewModel.foodItem.asObservable().subscribe(onNext: {value in
            //Texts
            let nameAndDescription = "\(value.name)\n\(value.description)"
            let nameTextAttribute: [NSAttributedStringKey: Any] = [
                .foregroundColor : UIColor.white,
                .strokeWidth : -2.0,
                .font : UIFont.boldSystemFont(ofSize: 20)
            ]
            let descriptionTextAttributes: [NSAttributedStringKey: Any] = [
                .foregroundColor : UIColor.white,
                .strokeWidth : -2.0,
                .font : UIFont.systemFont(ofSize: 14)
            ]
            let titleAttributedString = NSMutableAttributedString(string: nameAndDescription)
            titleAttributedString.setAttributes(nameTextAttribute, range: NSRange(location: 0,length: nameAndDescription.count))
            titleAttributedString.setAttributes(descriptionTextAttributes, range: (nameAndDescription as NSString).range(of: "\n\(value.description)"))

            self.nameAndDescriptionLabel.attributedText = titleAttributedString
            //tableview data
            if let toppingArray = value.ingredient_array{
                self.viewModel.toppingGroupOrder.append(ToppingGroup(items: []))
                for i in toppingArray {
                    self.viewModel.toppingGroupOrder[0].items.append(Topping(name: i, quantity: 1))
                }
            }
            
            self.viewModel.toppingGroups.accept(self.viewModel.toppingGroupOrder)
            
            
        }).disposed(by: disposeBag)
        //Image binding
        self.viewModel.image.subscribe(onNext: { value in
            let imageFilter = AspectScaledToFillSizeWithRoundedCornersFilter(
                size: self.foodImageView.frame.size,
                radius: 0
            )
            self.foodImageView.image = imageFilter.filter(value)
        }).disposed(by: disposeBag)
        
        //Table view Binding
        self.viewModel.toppingGroups.asDriver().drive(self.toppingTableView.rx.items(dataSource: self.viewModel.dataSource)).disposed(by: disposeBag)
    }
}
