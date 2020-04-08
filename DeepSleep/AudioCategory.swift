//
//  AudioCategory.swift
//  DeepSleep
//
//  Created by xinguang hu on 2020/4/8.
//  Copyright © 2020 wy. All rights reserved.
//

import UIKit

class AudioCategory: NSObject, Decodable {
    let id: Int!
    let name: String!
    let image_url: String!
    let musics: [AudioItem]!
}
