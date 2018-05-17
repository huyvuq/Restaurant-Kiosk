//
//  ItemCollectionViewCell.swift
//  Restaurant Kiosk
//
//  Created by Huy Vu on 5/13/18.
//  Copyright © 2018 VietMyApps. All rights reserved.
//

import UIKit
import AlamofireImage
import RxSwift
import RxCocoa
import RxDataSources

class FoodItemCollectionViewCell: UICollectionViewCell, FoodItemCellInterface {
    var foodItem : BehaviorRelay<FoodItem> = BehaviorRelay(value: FoodItem())
    let disposeBag = DisposeBag()
    
    @IBOutlet weak var foodImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        foodItem.asObservable().subscribe(onNext: {value in
            
            self.nameLabel.text = value.name
            
            //image
            if let imageURL = value.img_url {
                let imageCache = AutoPurgingImageCache()
                let imageCacheName = "\(imageURL)"
                let imageCacheURL =  URLRequest(url: URL(string: "\(imageURL)")!)
                let fileUrl = NSURL(string:  "\(imageURL)")
                
                //filter
                let filter = AspectScaledToFillSizeWithRoundedCornersFilter(
                    size: self.foodImageView.frame.size,
                    radius: 20.0
                )
                
                self.foodImageView.af_setImage(withURL: fileUrl! as URL,
                                                   placeholderImage: nil,
                                                   filter: filter,
                                                   completion: { response in
                                                        if response.result.isSuccess {
                                                            imageCache.add(response.result.value!, for: imageCacheURL, withIdentifier: imageCacheName)
                                                        }
                                                    })
            }
            
            self.addShadow()
        }).disposed(by: disposeBag)
        
        
        
    }

}


extension FoodItemCollectionViewCell{
    func addShadow(){
        self.contentView.layer.cornerRadius = 20.0
        self.contentView.layer.borderColor = UIColor.clear.cgColor
        
        self.contentView.layer.borderWidth = 1.0
        self.contentView.layer.masksToBounds = true
        
        self.layer.shadowOffset = CGSize(width: 2, height: 2)
        self.layer.shadowRadius = 3.5
        self.layer.shadowOpacity = 0.5
        self.layer.masksToBounds = false
        let newBounds = UIEdgeInsetsInsetRect(self.bounds, UIEdgeInsetsMake(10, 0, 0, 0))
        self.layer.shadowPath = UIBezierPath(roundedRect: newBounds, cornerRadius:self.contentView.layer.cornerRadius).cgPath
        
    }
}
