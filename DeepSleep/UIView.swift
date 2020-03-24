//
//  UIView.swift
//  DeepSleep
//
//  Created by xinguang hu on 2020/3/24.
//  Copyright © 2020 wy. All rights reserved.
//

import Foundation
import UIKit

extension UIView{
    public func setCorner(_ radius:CGFloat,_ roundingCorners:UIRectCorner)  {
        let fieldPath = UIBezierPath(roundedRect: bounds, byRoundingCorners: roundingCorners, cornerRadii:CGSize(width: radius, height: radius) )
        let fieldLayer = CAShapeLayer()
        fieldLayer.frame = bounds
        fieldLayer.path = fieldPath.cgPath
        layer.mask = fieldLayer
    }
    
}
