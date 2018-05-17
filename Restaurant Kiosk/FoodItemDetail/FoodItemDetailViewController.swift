//
//  FoodItemDetailViewController.swift
//  Restaurant Kiosk
//
//  Created by Huy Vu on 5/17/18.
//  Copyright © 2018 VietMyApps. All rights reserved.
//

import UIKit

class FoodItemDetailViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


    @IBAction func cancelButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
