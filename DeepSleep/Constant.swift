//
//  YbsConstant.swift
//  ItemFinder
//
//  Created by xinguang hu on 2019/8/8.
//  Copyright © 2019 huxinguang. All rights reserved.
//

import UIKit

struct Constant {
    
    static let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
    static let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String

    struct Thirdparty {
        static let umengAppKey = "5dd244f2570df366a0000460"
        static let wechatAppId = "wx210a7f52fe066572"
        static let wechatAppSecret = "89c8e7d4b4ba5d63111d1df7ba079344"
        static let wechatUniversalLink = "https://www.balamoney.com/starwelfare/"
        static let qqAppId = "101722175"
        static let qqAppKey = "5d6ebdd38b506d39c6c6baa7344a4828"
        static let qqUniversalLink = "https://www.balamoney.com/qq_conn/101722175"
    }
    
    struct UserDefaults {
        static let PlayerMode = "deepsleep.preference.key.name.playermode"
    }
    
    struct Folders {
        static let documents = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        static let temporary = NSTemporaryDirectory()
    }
    
    
}
