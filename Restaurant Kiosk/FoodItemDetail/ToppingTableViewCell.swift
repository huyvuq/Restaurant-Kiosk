//
//  ToppingTableViewCell.swift
//  Restaurant Kiosk
//
//  Created by Huy Vu on 5/17/18.
//  Copyright © 2018 VietMyApps. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class ToppingTableViewCell: UITableViewCell {
    var toppingItem : BehaviorRelay<Topping> = BehaviorRelay(value : Topping(name: "", quantity: 0))
    let disposeBag = DisposeBag()
    @IBOutlet weak var toppingLabel: UILabel!
    @IBOutlet weak var quantityLabel: UILabel!
    @IBOutlet weak var plustButtonOutlet: UIButton!
    @IBOutlet weak var minusButtonOutlet: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        plustButtonOutlet.roundCorner(radius: 15)
        minusButtonOutlet.roundCorner(radius: 15)
        
        toppingItem.asObservable().subscribe(onNext : { value in
            self.toppingLabel.text = value.name
            self.quantityLabel.text = "\(value.quantity)"
        }).disposed(by: disposeBag)
        
        plustButtonOutlet.rx.tap.bind {
            self.toppingItem.accept(self.toppingItem.value.increase())
        }.disposed(by: disposeBag)
        
        minusButtonOutlet?.rx.tap.bind {
            self.toppingItem.accept(self.toppingItem.value.decrease())
        }.disposed(by: disposeBag)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
