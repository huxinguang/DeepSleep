//
//  AnimatorObject.swift
//  DeepSleep
//
//  Created by xinguang hu on 2020/3/26.
//  Copyright © 2020 wy. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa


enum AnimatorType {
    case present
    case dismiss
}

class AnimatorObject: NSObject {
    
    fileprivate var type: AnimatorType!
    fileprivate var duration: TimeInterval!
    fileprivate let disposeBag = DisposeBag()

    convenience init(type: AnimatorType, duration: TimeInterval) {
        self.init()
        self.type = type
        self.duration = duration
    }
    
    deinit {
        print("AnimatorObject deinit")
    }
    
}

extension AnimatorObject: UIViewControllerAnimatedTransitioning{
    
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
            toVC.view.frame = CGRect(x: 0, y: -300 , width: UIScreen.main.bounds.size.width, height: 300)
            if let vc = toVC as? MusicTypeVC {
                dv.addTarget(vc, action: #selector(vc.onCloseBtn(_:)), for: .touchUpInside)
            }
        }else{
            fromVC.view.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 300)
        }
        
        dv.alpha = type == .present ? 0 : 1
        UIView.animate(withDuration: duration, animations: {
            if self.type == .present {
                toVC.view.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 300)
            }else{
                fromVC.view.frame = CGRect(x: 0, y: -300, width: UIScreen.main.bounds.size.width, height: 300)
            }
            
            dv.alpha = self.type == .present ? 1 : 0
        }) { (finished) in
            transitionContext.completeTransition(finished)
        }
        
    }
    
    

}
