//
//  Notification.swift
//  StarWelfare
//
//  Created by xinguang hu on 2020/1/9.
//  Copyright © 2020 weiyou. All rights reserved.
//

import Foundation

extension Notification.Name{
    struct App {
        static let DismissMusicTypeVC = Notification.Name(rawValue: "deepsleep.notification.name.DismissMusicTypeVC")
        static let PlayItemDidChange = Notification.Name(rawValue: "deepsleep.notification.name.PlayItemDidChange")
    }
}
