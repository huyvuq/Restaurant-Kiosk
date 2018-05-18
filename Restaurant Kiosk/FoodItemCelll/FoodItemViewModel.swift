//
//  FoodItemViewModel.swift
//
//
//  Created by Huy Vu on 5/18/18.
//

import UIKit
import AlamofireImage
import RxSwift
import RxCocoa
import RxDataSources

class FoodItemViewModel {
    //Reactive properties
    var foodItem : BehaviorRelay<FoodItem> = BehaviorRelay(value: FoodItem())
    var itemName : BehaviorRelay<String> = BehaviorRelay(value: "")
    var image : BehaviorRelay<UIImage> = BehaviorRelay(value: UIImage())
    let disposeBag = DisposeBag()
    
    //Properties
    init(){
        foodItem.asObservable().subscribe(onNext: { value in
            if let imageURL = value.img_url {
                if (!imageURL.isEmpty){
                    let imageCache = AutoPurgingImageCache()
                    let imageCacheName = "\(imageURL)"
                    let imageCacheURL =  URLRequest(url: URL(string: "\(imageURL)")!)
                    let fileUrl = NSURL(string:  "\(imageURL)")
                    
                    let uiImageView = UIImageView()
                    uiImageView.af_setImage(withURL: fileUrl! as URL,
                                                   placeholderImage: nil,
                                                   completion: { response in
                                                    if response.result.isSuccess {
                                                        imageCache.add(response.result.value!, for: imageCacheURL, withIdentifier: imageCacheName)
                                                        self.image.accept(response.result.value!)
                                                    }
                    })
                }
            }
            
            self.itemName.accept(value.name)
            
        }).disposed(by: disposeBag)
        
    }
}

