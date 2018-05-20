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
import Floaty

class MenuViewController : UIViewController {
    
    //MARK: - Outlets
    @IBOutlet fileprivate weak var collectionView: UICollectionView!
    @IBOutlet weak var sideView: UIView!
    @IBOutlet weak var sideViewBlurView: UIVisualEffectView!
    @IBOutlet weak var sideViewConstraint: NSLayoutConstraint!
    
    @IBOutlet var sideViewTableView: UITableView!
    @IBOutlet weak var placeOrderButton: UIButton!
    
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

        //Cart View (side)
        self.setSideView()
        
        //Floating buttons
        self.setUpFloatingButtons()
        
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
        var cellWidth = CGFloat(UIScreen.main.bounds.width/2 - 30.0)
        if cellWidth >= 200{
            cellWidth = 200
        }
        return CGSize(width: cellWidth, height: cellWidth)
    }

}


//MARK : - Side View
extension MenuViewController {
    func setSideView(){
        sideView.layer.shadowColor = UIColor.black.cgColor
        sideView.layer.shadowOpacity = 0.5
        sideView.layer.shadowOffset = CGSize(width: 2, height: 2)
        sideViewConstraint.constant = -200
        placeOrderButton.addShadow()
        
        self.viewModel.cart.asDriver().drive(sideViewTableView.rx.items(dataSource: self.viewModel.cartDataSource)).disposed(by: bag)
        
        self.sideViewTableView.rx.setDelegate(self).disposed(by: bag)
        self.placeOrderButton.rx.tap.bind {
            print("Placing order: ")
            self.viewModel.placeOrder()
            }.disposed(by: bag)
        
        self.viewModel.orderStatus.asObservable().subscribe(onNext: {value in
            switch value {
            case .failure:
                let alert = UIAlertController(title: "Failure", message: "There was a problem placing the order, please try again", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            case .success:
                let alert = UIAlertController(title: "Success", message: "Order placed", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: {
                    self.viewModel.orderStatus.value = OrderStatus.processed
                })
            case .inOrder:
                print("Order in process")
            case .processed:
                print("Processed")
            case .cartEmpty:
                let alert = UIAlertController(title: "Alert", message: "Cart is empty", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: {self.viewModel.orderStatus.value = OrderStatus.processed})
            }
        }).disposed(by: bag)
        
        sideViewTableView.setEditing(true, animated: true)
        sideViewTableView.rx.itemDeleted.asObservable().subscribe({indexPath in
            self.viewModel.cart.value[(indexPath.element?.section)!].items.remove(at: (indexPath.element?.row)!)
        }).disposed(by: bag)
    }
    
    //MARK : - Action
    @IBAction func panPerformed(_ sender: UIPanGestureRecognizer) {
        if sender.state == .began || sender.state == .changed {
            let translation = sender.translation(in: self.view).x
            if translation > 0 { //Swipe right
                if sideViewConstraint.constant < 30 {
                    UIView.animate(withDuration: 0.2, animations: {
                        self.sideViewConstraint.constant += translation/10
                        self.sideView.layoutIfNeeded()
                    })
                }
            } else { //Swipe left
                if sideViewConstraint.constant > -200 {
                    UIView.animate(withDuration: 0.2, animations: {
                        self.sideViewConstraint.constant += translation/10
                        self.sideView.layoutIfNeeded()
                    })
                }
            }
        } else if sender.state == .ended {
            UIView.animate(withDuration: 0.3, animations: {
                self.sideViewConstraint.constant = self.sideViewConstraint.constant > -80 ? 10 : -200
                self.sideView.layoutIfNeeded()
            })
        }
    }
}
//MARK: - Floaty buttons
extension MenuViewController {
    
    func setUpFloatingButtons(){
        let floaty = Floaty()
        floaty.buttonColor = UIColor.transparentBlack()
        floaty.plusColor = UIColor.white
        
        //Buttons
        let cartButton = FloatyItem()
        cartButton.buttonColor = UIColor.transparentBlack()
        cartButton.iconImageView.image = UIImage(named: "cart")!
        cartButton.title = "Cart"
        cartButton.handler = { item in
            UIView.animate(withDuration: 0.3, animations: {
                self.sideViewConstraint.constant = 10
                self.sideView.layoutIfNeeded()
            })
        }
        floaty.addItem(item: cartButton)
        
        let placeOrderButton = FloatyItem()
        placeOrderButton.buttonColor = UIColor.transparentBlack()
        placeOrderButton.iconImageView.image = UIImage(named: "purchase")!
        placeOrderButton.title = "Place Order"
        placeOrderButton.handler = { item in
            print("Placing order")
            self.viewModel.placeOrder()
        }
        floaty.addItem(item: placeOrderButton)
        
        let viewReceiptButton = FloatyItem()
        viewReceiptButton.buttonColor = UIColor.transparentBlack()
        viewReceiptButton.iconImageView.image = UIImage(named: "check")!
        viewReceiptButton.title = "View Receipt(s)"
        viewReceiptButton.handler = { item in
            self.navigationController?.pushViewController(self.viewModel.receiptViewController, animated: true)
        }
        floaty.addItem(item: viewReceiptButton)
        
        self.view.addSubview(floaty)
    }
}
