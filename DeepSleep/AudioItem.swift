//
//  AudioItem.swift
//  DeepSleep
//
//  Created by xinguang hu on 2020/3/30.
//  Copyright © 2020 wy. All rights reserved.
//

import UIKit

class AudioItem: NSObject {
    var id: Int!
    var url: String!
    var name: String!    
    
    init(fromDictionary dictionary: NSDictionary) {
        self.id = dictionary["id"] as? Int
        self.url = dictionary["url"] as? String
        self.name = dictionary["name"] as? String
    }
    
}
