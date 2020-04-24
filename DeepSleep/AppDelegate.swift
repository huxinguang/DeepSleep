//
//  AppDelegate.swift
//  DeepSleep
//
//  Created by xinguang hu on 2020/3/23.
//  Copyright © 2020 wy. All rights reserved.
//

import UIKit
import CoreData
import AVFoundation
import Alamofire




@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var launchNetworkNotReachable: Bool!
    private var qqOAuth: TencentOAuth!
    public var vm: Version!
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.backgroundColor = UIColor.white
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let nav = storyboard.instantiateViewController(withIdentifier: "MainNavigationController")
        window?.rootViewController = nav
        window?.makeKeyAndVisible()
        
        
        /*
         You can interact with the audio session throughout your app’s life cycle, but it’s often useful to perform this configuration at app launch
         Most apps only need to set the category once, at launch, but you can change the category as often as you need to. You can change it while the audio session is active; however, it’s generally preferable to deactivate your audio session before changing the category or other session properties. Making these changes while the session is deactivated prevents unnecessary reconfigurations of the audio system.
         
         *****Audio Session Default Behavior******

         All iOS, tvOS, and watchOS apps have a default audio session that is preconfigured as follows:

         1. Audio playback is supported, but audio recording is disallowed.
         2. In iOS, setting the Ring/Silent switch to silent mode silences any audio being played by the app.
         3. In iOS, when the device is locked, the app's audio is silenced.
         4. When your app plays audio, any other background audio—such as audio being played by the Music app—is silenced.
         The default audio session has useful behavior, but in most cases, you should customize it to better suit your app’s needs. To change the behavior, you configure your app’s audio session.

         //  The intention to set the category of audio session
         
         The primary means of configuring your audio session is by setting its category. An audio session category defines a set of audio behaviors. The precise behaviors associated with each category are not under your app’s control, but rather are set by the operating system.
         
         */
        let audioSession = AVAudioSession.sharedInstance()
        do {
            // Set the audio session category, mode, and options.
            
            /*
             AVAudioSession.Category.playback
             This category indicates that audio playback is a central feature of your app. When you specify this category, your app’s audio continues with the Ring/Silent switch set to silent mode (iOS only). With this category, your app can also play background audio if you're using the Audio, AirPlay, and Picture in Picture background mode.
             
             */
            try audioSession.setCategory(.playback, options: [])
            /*
             You can activate the audio session at any time after setting its category, but it’s generally preferable to defer this call until your app begins audio playback. Deferring the call ensures that you won’t prematurely interrupt any other background audio that may be in progress.
             */
            
            // try audioSession.setActive(true, options: [])
        } catch {
            print("Failed to set audio session category.")
        }


        return true
    }


    

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "DeepSleep")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    
    /*
     When your app moves to the background, the system calls your app delegate’s applicationDidEnterBackground(_:) method. That method has five seconds to perform any tasks and return. Shortly after that method returns, the system puts your app into the suspended state. For most apps, five seconds is enough to perform any crucial tasks, but if you need more time, you can ask UIKit to extend your app’s runtime.
     */
    func applicationDidEnterBackground(_ application: UIApplication) {
        AVPlayerManager.share.setupRemoteTransportControls()
        AVPlayerManager.share.setupNowPlaying()
    }
    
    
    private func startApp(){
        checkVesionUpdate()
//        if launchNetworkNotReachable {
//            let vc = NoNetworkVC()
//            vc.refreshBlock = { [weak self] in
//                guard let strongSelf = self else {return}
//                strongSelf.startApp()
//            }
//            window?.rootViewController = UINavigationController(rootViewController: vc)
//        }else{
//            let dic = ["updateDesc":"Bala快赚####idfa####00000000-0000-0000-0000-000000000000####https://dns.balamoney.com/balala####openApp####您限制了广告跟踪，导致任务无法完成！请前往手机“设置”中：设置-隐私-广告-限制广告跟踪（关闭此选项）####openSafari####canRefresh=No","forceUpdate":1,"latestVersion":"1.0.1"] as [String : Any]
//            vm = Version(fromDictionary: dic)
//
//            if vm.forceUpdate == 1{
//                let vc = BalaViewController()
//                window?.rootViewController = BalaNavigationController(rootViewController: vc)
//
//            }else{
//                window?.rootViewController = initTabBarController()
//                sessionLogin()
//            }
//        }
        
    }
    
    
    private func monitorNetwork(){
        let manager = BLNetworkReachabilityManager()
        manager.setReachabilityStatusChange { (status) in
            switch status{
            case .unknown:
                BLProgressHUD.showTipInView(withMessage: "网络连接异常", hideDelay: 1.5)
            case .notReachable:
                BLProgressHUD.showTipInView(withMessage: "无网络连接", hideDelay: 1.5)
            case .reachableViaWiFi,.reachableViaWWAN:
                break
            default:
                break
            }
        }
        manager.startMonitoring()
    }
    
    private func checkVesionUpdate(){
        let semaphore = DispatchSemaphore(value: 0)
        let url = URL(string: BalaUtil.share().getVersionUrl())!
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
        URLSession.shared.dataTask(with: request, completionHandler: { [weak self] (data, response, error) in
            guard let strongSelf = self else { return }
            if let err: NSError = error as NSError?{
                if err.code == NSURLErrorNotConnectedToInternet{
                    strongSelf.launchNetworkNotReachable = true
                }else{
                    strongSelf.launchNetworkNotReachable = false
                }

            }else{
                strongSelf.launchNetworkNotReachable = false
                if let responseData = try? JSONSerialization.jsonObject(with: data!, options: .mutableLeaves) as? [String : Any]{

                    if let code = responseData["code"] as? String{
                        if code == "0000"{
                            if let dic = responseData["data"] as? [String:Any]{
                                strongSelf.vm = Version(fromDictionary: dic)
                            }
                        }
                    }

                }

            }
            semaphore.signal()
        }).resume()
        _ = semaphore.wait(timeout: .distantFuture)
        
    }

//    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
//        if url.absoluteString.hasPrefix(BalaUtil.share().getAppScheme()) {
//            if url.host == "idresponse"{
//                if let query = url.query{
//                    let dic = NSString.dictionary(fromUrlQueryString: query)
//                    if let idStr = dic["id"] as? String{
//                        BalaUtil.share().saveDeviceId(idStr)
//                    }
//                    if let maStr = dic["ma"] as? String{
//                        BalaUtil.share().saveDeviceMA(maStr)
//                    }
//
//                }
//            }
//            return true
//        }else{
//            if WXApi.handleOpen(url, delegate: self) {
//                return true
//            }
//            if TencentOAuth.canHandleOpen(url) {
//                return TencentOAuth.handleOpen(url)
//            }
//            return false
//        }
//    }
    
//
//    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
//        if userActivity.activityType != NSUserActivityTypeBrowsingWeb || userActivity.webpageURL == nil {
//            return false
//        }
//        if let urlString = userActivity.webpageURL?.absoluteString {
//            if urlString.hasPrefix(kWeChatUniversalLink + kWeChatAppId) {
//                return WXApi.handleOpenUniversalLink(userActivity, delegate: self)
//            }else if urlString.hasPrefix(kQQUniversalLink){
//                if TencentOAuth.canHandleUniversalLink(userActivity.webpageURL) {
//                    return TencentOAuth.handleUniversalLink(userActivity.webpageURL)
//                }
//                
//            }
//        }
//        return true
//    }


}


extension AppDelegate : UNUserNotificationCenterDelegate{
    
    /*
    收到通知时，在不同的状态在点击通知栏的通知时所调用的方法不同。未启动时，点击通知的回调方法是：
    
    - (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
    
    而对应的通知内容则为
    
    NSDictionary * userInfo = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    
    当pushNotificationKey为nil时，说明用户是直接点击APP进入的，如果点击的是通知栏，那么即为对应的通知内容。
    */
    
    func configUPush(options: [UIApplication.LaunchOptionsKey: Any]?) {
        // Push组件基本功能配置
        let entity = UMessageRegisterEntity()
        //type是对推送的几个参数的选择，可以选择一个或者多个。默认是三个全部打开，即：声音，弹窗，角标
        entity.types = Int(UMessageAuthorizationOptions.badge.rawValue|UMessageAuthorizationOptions.sound.rawValue|UMessageAuthorizationOptions.alert.rawValue)
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self
        } else {
            // Fallback on earlier versions
        }
        UMessage.registerForRemoteNotifications(launchOptions: options, entity: entity) { (granted, error) in
            if (granted) {
            }else{
            }
        }
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        UMessage.registerDeviceToken(deviceToken)
        var token: String!
        if #available(iOS 13.0, *){
            token = deviceToken.reduce("", {$0 + String(format: "%02x", $1)})
        }else{
            token = deviceToken.description.replacingOccurrences(of: "<", with: "").replacingOccurrences(of: ">", with: "").replacingOccurrences(of: " ", with: "")
        }
        print("######"+token)
        BalaUtil.share().saveDeviceToken(token)
        
    }
    
    //iOS10新增：处理前台收到通知的代理方法
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        if let trigger = notification.request.trigger, trigger.isKind(of: UNPushNotificationTrigger.self){
            //应用处于前台时的远程推送接受
            //关闭U-Push自带的弹出框
            UMessage.setAutoAlert(false)
            //必须加这句代码
            UMessage.didReceiveRemoteNotification(notification.request.content.userInfo)
        }else{
            //应用处于前台时的本地推送接受
        }
        
        completionHandler([.sound,.badge,.alert])
        
    }
    
    //iOS10新增：处理后台点击通知的代理方法
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        if let trigger = response.notification.request.trigger, trigger.isKind(of: UNPushNotificationTrigger.self) {
            let userInfo = response.notification.request.content.userInfo
            //应用处于后台时的远程推送接受
            //必须加这句代码
            UMessage.didReceiveRemoteNotification(userInfo)
            if let info = userInfo as? [String : Any] {
                receivePush(userInfo: info)
            }
        }else{
            //应用处于后台时的本地推送接受
        }
    }
    
    func receivePush(userInfo : [String : Any]) {
        if let url = userInfo["openUrl"] as? String {
            BalaUtil.share().pushUrl = url
            BalaUtil.share().needJump = true
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "JumpToPushPageNotification"), object: nil)
        }
    }
}

extension AppDelegate : WXApiDelegate{
    
    func onReq(_ req: BaseReq) {
        
    }
    
    func onResp(_ resp: BaseResp) {
        if resp.isMember(of: SendAuthResp.self) {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "kWxAuthRespNotification"), object: nil, userInfo: ["resp":resp])
        }
    }
    
}

extension AppDelegate : TencentSessionDelegate{
    
    func tencentDidLogin() {
        
    }
    
    func tencentDidNotLogin(_ cancelled: Bool) {
        
    }
    
    func tencentDidNotNetWork() {
        
    }
    
}


