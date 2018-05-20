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
    var foodItemmViewModel = FoodItemViewModel()
    var disposeBag = DisposeBag()
    @IBOutlet weak var foodImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        foodItemmViewModel.itemName.subscribe(onNext: { value in
            self.nameLabel.text = value
        }).disposed(by: disposeBag)
        
        foodItemmViewModel.image.subscribe(onNext: { value in
            let imageFilter = AspectScaledToFillSizeWithRoundedCornersFilter(
                size: self.foodImageView.frame.size,
                radius: 0
            )
            self.foodImageView.image = imageFilter.filter(value)
            
            self.roundedCell()
        }).disposed(by: disposeBag)
    }

}


