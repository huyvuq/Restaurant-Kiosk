//
//  ReceiptViewController.swift
//  Restaurant Kiosk
//
//  Created by Huy Vu on 5/19/18.
//  Copyright © 2018 VietMyApps. All rights reserved.
//

import UIKit
import Alamofire
import RxSwift
import RxCocoa
import RxAlamofire
import RxDataSources

class ReceiptViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    

    //Reactive
    let receiptDataSource = RxTableViewSectionedReloadDataSource<ReceiptGroup>( configureCell: { (_, _, _, _) in fatalError()})
    let bag = DisposeBag()
    //Receipts
    var receipts : Variable<[Receipt]> = Variable([])
    var receiptGroup : BehaviorRelay<[ReceiptGroup]> = BehaviorRelay(value:[])
    let receiptViewController = UIStoryboard(name: "Main", bundle:nil)
        .instantiateViewController(withIdentifier: "ReceiptDetailView") as! ReceiptDetailViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        
        receipts.asObservable().subscribe(onNext: {value in
            self.receiptGroup.accept([ReceiptGroup(header: "list", items: value)])
        }).disposed(by: bag)
        
        receiptDataSource.configureCell = {_, tableView, indexPath, item in
            let cell = tableView.dequeueReusableCell(withIdentifier: "ReceiptCell", for: indexPath) as! ReceiptTableViewCell
            cell.receipt.value = item
            return cell
        }
        
        tableView.rx.modelSelected(Receipt.self).subscribe(onNext : { value in
            self.receiptViewController.receipt.value = value
            self.navigationController?.pushViewController(self.receiptViewController, animated: true)
        }).disposed(by: bag)
        receiptGroup.asDriver().drive(tableView.rx.items(dataSource: receiptDataSource)).disposed(by: bag)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.fetchData()
    }
}


extension ReceiptViewController{
    func fetchData(){
        let URL = serverURL?.appendingPathComponent("GetOrders")
        RxAlamofire.requestJSON(.get, URL!).subscribe(onNext: {(r, value) in
            let json = JSON(value)
            if json["status"]=="success"{
                let dict = try! JSONSerialization.jsonObject(with: json["item_list"].rawData(), options: [])
                let data = try! JSONSerialization.data(withJSONObject: dict, options: [])
                let items = try! JSONDecoder().decode([Receipt].self, from: data)
                self.receipts.value = items
            }
            }, onError: { error in
                print(error)
        }).disposed(by: bag)
    }
}
