//
//  UIButton.swift
//  FlowerLover
//
//  Created by xinguang hu on 2020/2/21.
//  Copyright © 2020 xjy. All rights reserved.
//

import UIKit

private var selectedImageHandle: UInt8 = 0

extension UIButton{
    
    @IBInspectable
    var selectedImage: UIImage? {
        get {
            if let image = objc_getAssociatedObject(self, &selectedImageHandle) as? UIImage {
                return image
            }
            return nil
        }
        set {
            if let image = newValue {
                setImage(image, for: .selected)
                objc_setAssociatedObject(self, &selectedImageHandle, image, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            } else {
                objc_setAssociatedObject(self, &selectedImageHandle, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }
    
}
