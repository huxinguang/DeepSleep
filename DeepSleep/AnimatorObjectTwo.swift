//
//  AnimatorObjectTwo.swift
//  DeepSleep
//
//  Created by xinguang hu on 2020/3/27.
//  Copyright © 2020 wy. All rights reserved.
//

import UIKit

class AnimatorObjectTwo: NSObject {
    fileprivate var type: AnimatorType!
    fileprivate var duration: TimeInterval!

    convenience init(type: AnimatorType, duration: TimeInterval) {
        self.init()
        self.type = type
        self.duration = duration
    }
}

extension AnimatorObjectTwo: UIViewControllerAnimatedTransitioning{
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let toVC = transitionContext.viewController(forKey: .to), let fromVC = transitionContext.viewController(forKey: .from) else {
            transitionContext.completeTransition(true)
            return
        }
        
        let dv = UIControl(frame: UIScreen.main.bounds)
        dv.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        transitionContext.containerView.addSubview(dv)
        
        dv.addSubview(type == .present ? toVC.view : fromVC.view)
        
        if type == .present {
            toVC.view.frame = CGRect(x: 0, y: -500 , width: UIScreen.main.bounds.size.width, height: 500)
        }else{
            fromVC.view.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 500)
        }
        
        dv.alpha = type == .present ? 0 : 1
        UIView.animate(withDuration: duration, animations: {
            if self.type == .present {
                toVC.view.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 500)
            }else{
                fromVC.view.frame = CGRect(x: 0, y: -500, width: UIScreen.main.bounds.size.width, height: 500)
            }
            
            dv.alpha = self.type == .present ? 1 : 0
        }) { (finished) in
            transitionContext.completeTransition(finished)
        }
        
    }
    
    

}
