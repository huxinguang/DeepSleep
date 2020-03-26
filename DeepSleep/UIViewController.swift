//
//  UIViewController.swift
//  DeepSleep
//
//  Created by xinguang hu on 2020/3/26.
//  Copyright © 2020 wy. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController{
    
    fileprivate struct AssociatedKeys {
        static var presentationDelegateKey = "PresentationDelegateKey"
    }
    
    var presentationDelegate: PresentationDelegateObject? {
        get{
            var delegate = objc_getAssociatedObject(self, &AssociatedKeys.presentationDelegateKey) as? PresentationDelegateObject
            if delegate == nil{
                delegate = PresentationDelegateObject()
                objc_setAssociatedObject(self, &AssociatedKeys.presentationDelegateKey, delegate, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
            return delegate
        }
        set{
            objc_setAssociatedObject(self, &AssociatedKeys.presentationDelegateKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    

    
    
}
