//
//  CollectionViewImageCell.swift
//  RxExample
//
//  Created by PowerMobile Team on 4/4/15.
//  Copyright © 2015 PowerMobile Team. All rights reserved.
//

import UIKit
#if !RX_NO_MODULE
import RxSwift
import RxCocoa
#endif

public class CollectionViewImageCell: UICollectionViewCell {
    @IBOutlet var imageOutlet: UIImageView!
    
    var disposeBag: DisposeBag?

    var downloadableImage: Observable<DownloadableImage>?{
        didSet{
            let disposeBag = DisposeBag()

            self.downloadableImage?
                .asDriver(onErrorJustReturn: DownloadableImage.offlinePlaceholder)
                .drive(imageOutlet.rx.downloadableImageAnimated(kCATransitionFade))
                .disposed(by: disposeBag)

            self.disposeBag = disposeBag
        }
    }
    
    override public func prepareForReuse() {
        super.prepareForReuse()
        
        downloadableImage = nil
        disposeBag = nil
    }

    deinit {
    }
}
