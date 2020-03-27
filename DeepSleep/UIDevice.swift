//
//  UIDevice.swift
//  fish
//
//  Created by xinguang hu on 2019/9/10.
//  Copyright © 2019 huxinguang. All rights reserved.
//

import UIKit

extension UIDevice{
    
    //iPhone navigationBar 高度 44.0
    //ipad navigationBar 高度 50.0
    
    //iPhone 非全面屏和全面屏 横屏时都默认不显示状态栏
    
    //iPhone 8 plus 竖屏 UIEdgeInsets(top: 20.0, left: 0.0, bottom: 0.0, right: 0.0)
    //iPhone 8 plus 横屏 UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
    
    
    //iPhone 11 pro 竖屏 UIEdgeInsets(top: 44.0, left: 0.0, bottom: 34.0, right: 0.0)
    //iPhone 11 pro 横屏 UIEdgeInsets(top: 0.0, left: 44.0, bottom: 21.0, right: 44.0)
    
    //iPhone 11 pro 13.0 横屏 navigationBar 32.0   tabbar高度 53.0
    //iPhone X 12.2 横屏 navigationBar 32.0   tabbar高度 83.0
    

    //iPad 非全面屏和全面屏 横屏时都默认显示状态栏
    
    //ipad pro 2g 竖屏 UIEdgeInsets(top: 20.0, left: 0.0, bottom: 0.0, right: 0.0)
    //ipad pro 2g 横屏 UIEdgeInsets(top: 20.0, left: 0.0, bottom: 0.0, right: 0.0)
    
    //ipad pro 3g 竖屏
    //UIEdgeInsets(top: 24.0, left: 0.0, bottom: 20.0, right: 0.0)
    //ipad pro 3g 横屏（默认显示状态栏）
    //UIEdgeInsets(top: 24.0, left: 0.0, bottom: 20.0, right: 0.0)
    
    static var isFullScreen: Bool {
        if #available(iOS 11, *) {
              guard let w = UIApplication.shared.delegate?.window, let unwrapedWindow = w else {
                  return false
              }
              if unwrapedWindow.safeAreaInsets.left > 0 || unwrapedWindow.safeAreaInsets.bottom > 0 {
                  print(unwrapedWindow.safeAreaInsets)
                  return true
              }
        }
        return false
    }
    
    
    static var platform: String{
        var systemInfo = utsname()
        uname(&systemInfo)
        let platform = withUnsafePointer(to: &systemInfo.machine.0) { ptr in
            return String(cString: ptr)
        }
        if platform == "iPhone1,1" { return "iPhone"}
        if platform == "iPhone1,2" { return "iPhone 3G"}
        if platform == "iPhone2,1" { return "iPhone 3GS"}
        if platform == "iPhone3,1" { return "iPhone 4"}
        if platform == "iPhone3,2" { return "iPhone 4"}
        if platform == "iPhone3,3" { return "iPhone 4"}
        if platform == "iPhone4,1" { return "iPhone 4S"}
        if platform == "iPhone5,1" { return "iPhone 5"}
        if platform == "iPhone5,2" { return "iPhone 5"}
        if platform == "iPhone5,3" { return "iPhone 5C"}
        if platform == "iPhone5,4" { return "iPhone 5C"}
        if platform == "iPhone6,1" { return "iPhone 5S"}
        if platform == "iPhone6,2" { return "iPhone 5S"}
        if platform == "iPhone7,1" { return "iPhone 6 Plus"}
        if platform == "iPhone7,2" { return "iPhone 6"}
        if platform == "iPhone8,1" { return "iPhone 6S"}
        if platform == "iPhone8,2" { return "iPhone 6S Plus"}
        if platform == "iPhone8,4" { return "iPhone SE"}
        if platform == "iPhone9,1" { return "iPhone 7"}
        if platform == "iPhone9,2" { return "iPhone 7 Plus"}
        if platform == "iPhone9,3" { return "iPhone 7"}
        if platform == "iPhone9,4" { return "iPhone 7 Plus"}
        if platform == "iPhone10,1" { return "iPhone 8"}
        if platform == "iPhone10,2" { return "iPhone 8 Plus"}
        if platform == "iPhone10,3" { return "iPhone X"}
        if platform == "iPhone10,4" { return "iPhone 8"}
        if platform == "iPhone10,5" { return "iPhone 8 Plus"}
        if platform == "iPhone10,6" { return "iPhone X"}
        if platform == "iPhone11,2" { return "iPhone XS"}
        if platform == "iPhone11,4" { return "iPhone XS Max"}
        if platform == "iPhone11,6" { return "iPhone XS Max"}
        if platform == "iPhone11,8" { return "iPhone XR"}
        if platform == "iPhone12,1" { return "iPhone 11"}
        if platform == "iPhone12,3" { return "iPhone 11 Pro"}
        if platform == "iPhone12,5" { return "iPhone 11 Pro Max"}
        
        if platform == "iPod1,1" { return "iPod Touch"}
        if platform == "iPod2,1" { return "iPod Touch 2"}
        if platform == "iPod3,1" { return "iPod Touch 3"}
        if platform == "iPod4,1" { return "iPod Touch 4"}
        if platform == "iPod5,1" { return "iPod Touch 5"}
        if platform == "iPod7,1" { return "iPod Touch 6"}
        if platform == "iPod9,1" { return "iPod Touch 7"}
        
        if platform == "iPad1,1" { return "iPad 1"}
        if platform == "iPad2,1" { return "iPad 2"}
        if platform == "iPad2,2" { return "iPad 2"}
        if platform == "iPad2,3" { return "iPad 2"}
        if platform == "iPad2,4" { return "iPad 2"}
        if platform == "iPad2,5" { return "iPad Mini"}
        if platform == "iPad2,6" { return "iPad Mini"}
        if platform == "iPad2,7" { return "iPad Mini"}
        if platform == "iPad3,1" { return "iPad 3"}
        if platform == "iPad3,2" { return "iPad 3"}
        if platform == "iPad3,3" { return "iPad 3"}
        if platform == "iPad3,4" { return "iPad 4"}
        if platform == "iPad3,5" { return "iPad 4"}
        if platform == "iPad3,6" { return "iPad 4"}
        if platform == "iPad4,1" { return "iPad Air"}
        if platform == "iPad4,2" { return "iPad Air"}
        if platform == "iPad4,3" { return "iPad Air"}
        if platform == "iPad4,4" { return "iPad Mini 2"}
        if platform == "iPad4,5" { return "iPad Mini 2"}
        if platform == "iPad4,6" { return "iPad Mini 2"}
        if platform == "iPad4,7" { return "iPad Mini 3"}
        if platform == "iPad4,8" { return "iPad Mini 3"}
        if platform == "iPad4,9" { return "iPad Mini 3"}
        if platform == "iPad5,1" { return "iPad Mini 4"}
        if platform == "iPad5,2" { return "iPad Mini 4"}
        if platform == "iPad5,3" { return "iPad Air 2"}
        if platform == "iPad5,4" { return "iPad Air 2"}
        if platform == "iPad6,3" { return "iPad Pro 9.7"}
        if platform == "iPad6,4" { return "iPad Pro 9.7"}
        if platform == "iPad6,7" { return "iPad Pro 12.9"}
        if platform == "iPad6,8" { return "iPad Pro 12.9"}
        if platform == "iPad6,11" { return "iPad 5"}
        if platform == "iPad6,12" { return "iPad 5"}
        if platform == "iPad7,1" { return "iPad Pro 12.9"}
        if platform == "iPad7,2" { return "iPad Pro 12.9"}
        if platform == "iPad7,3" { return "iPad Pro 10.5"}
        if platform == "iPad7,4" { return "iPad Pro 10.5"}
        if platform == "iPad7,5" { return "iPad 6"}
        if platform == "iPad7,6" { return "iPad 6"}
        if platform == "iPad8,1" { return "iPad Pro 11"}
        if platform == "iPad8,2" { return "iPad Pro 11"}
        if platform == "iPad8,3" { return "iPad Pro 11"}
        if platform == "iPad8,4" { return "iPad Pro 11"}
        if platform == "iPad8,5" { return "iPad Pro 12.9"}
        if platform == "iPad8,6" { return "iPad Pro 12.9"}
        if platform == "iPad8,7" { return "iPad Pro 12.9"}
        if platform == "iPad8,8" { return "iPad Pro 12.9"}
        if platform == "iPad11,1" { return "iPad Mini 5"}
        if platform == "iPad11,2" { return "iPad Mini 5"}
        if platform == "iPad11,3" { return "iPad Air 3"}
        if platform == "iPad11,4" { return "iPad Air 3"}
        if platform == "iPad7,11" { return "iPad 7 WiFi"}
        if platform == "iPad7,12" { return "iPad 7 WiFi+Cellular"}
        
        if platform == "i386"   { return "iPhone Simulator"}
        if platform == "x86_64" { return "iPhone Simulator"}
        
        return platform
    }

}
