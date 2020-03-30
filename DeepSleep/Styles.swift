//
//  Styles.swift
//  StarWelfare
//
//  Created by xinguang hu on 2020/1/9.
//  Copyright © 2020 weiyou. All rights reserved.
//

import Foundation
import UIKit

struct Styles {
    
    struct Adapter {
        static let scale = UIScreen.main.bounds.size.width/375.0
    }

    struct Fonts {
        static let pfscR: String = "PingFangSC-Regular"
        static let pfscM: String = "PingFangSC-Medium"
        static let pfscS: String = "PingFangSC-Semibold"
    }
    
    struct Color {
        
    }
    
    struct Constant {
        static let music_type_view_height = UIScreen.main.bounds.size.height*0.382
        static let music_type_list_view_height = UIScreen.main.bounds.size.height*0.618
        
    }

}