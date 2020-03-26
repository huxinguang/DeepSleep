//
//  TopPresentationDelegate.swift
//  DeepSleep
//
//  Created by xinguang hu on 2020/3/26.
//  Copyright © 2020 wy. All rights reserved.
//

import UIKit

class PresentationDelegateObject: NSObject {
    
    

}

extension PresentationDelegateObject: UIViewControllerTransitioningDelegate{
    /*
     You can provide separate animator objects for presenting and dismissing the view controller.
     此方法返回的CustomPresentationController实例就是一个animator object，如果presenting和dismissing使用的是不同的animator object， 可以在在协议方法
     
     animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning?
     
     中返回一个新的animator object
     
     */
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return CustomPresentationController(presentedViewHeight: UIScreen.main.bounds.size.height*0.7, presentedViewController: presented, presenting: presenting)
    }
    

    
    
}


