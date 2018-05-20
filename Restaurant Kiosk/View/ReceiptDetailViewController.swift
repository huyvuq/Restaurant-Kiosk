//
//  ReceiptDetailViewController.swift
//  Restaurant Kiosk
//
//  Created by Huy Vu on 5/19/18.
//  Copyright © 2018 VietMyApps. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ReceiptDetailViewController: UIViewController {
    
    @IBOutlet weak var viewRegion: UIView!
    var receipt : Variable<Receipt> = Variable(Receipt())
    let bag = DisposeBag()
    
    @IBOutlet weak var printButton: UIButton!
    @IBOutlet weak var receiptDetailLabel: UITextView!
    @IBOutlet weak var retaurantNameLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        viewRegion.addShadow()
        retaurantNameLabel.text = "The Udon Club\n123 Main Street,\nJersey City,NJ 08401\n609-555-5555"
        printButton.addShadow()
        
        receipt.asObservable().subscribe(onNext: {value in
            var text = ""
            text.append("Order #: \(value.id)")
            text.append("\nDate: \(value.order_date)")
            for i in value.order_detail!{
                text.append("\n\(i.header): ")
                for j in i.items {
                    text.append("\n\t-\(j.name):")
                    for k in j.topping {
                        text.append(" \(k.value) \(k.key)(s)")
                    }
                }
            }
            self.receiptDetailLabel.text = text
        }).disposed(by: bag)
        
        printButton.rx.tap.bind(onNext: {
            print("printing")
        }).disposed(by: bag)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}
