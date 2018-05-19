//
//  ReceiptTableViewCell.swift
//  Restaurant Kiosk
//
//  Created by Huy Vu on 5/19/18.
//  Copyright © 2018 VietMyApps. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ReceiptTableViewCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    
    var receipt : Variable<Receipt> = Variable(Receipt())
    let bag = DisposeBag()
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        receipt.asObservable().subscribe(onNext : {item in
//            print(item)
            self.titleLabel.text = "Receipt #: \(item.id)"
            self.subtitleLabel.text = "Date: \(item.order_date)"
        }).disposed(by: bag)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
