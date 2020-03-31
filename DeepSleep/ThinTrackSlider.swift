//
//  ThinTrackSlider.swift
//  DeepSleep
//
//  Created by xinguang hu on 2020/3/31.
//  Copyright © 2020 wy. All rights reserved.
//

import UIKit

class ThinTrackSlider: UISlider {
    
    override func trackRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(x: 0, y: 0, width: bounds.size.width, height: 1.5)
    }

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
