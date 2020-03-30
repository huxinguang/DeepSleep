//
//  AudioItem.swift
//  DeepSleep
//
//  Created by xinguang hu on 2020/3/30.
//  Copyright © 2020 wy. All rights reserved.
//

import UIKit

class AudioItem: NSObject {
    var url: String!
    var name: String!    
    
    init(withUrl url: String) {
        self.url = url
    }
    
}
