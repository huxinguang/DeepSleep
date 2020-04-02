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

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        sleep(2)
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.backgroundColor = UIColor.white
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let nav = storyboard.instantiateViewController(withIdentifier: "MainNavigationController")
        window?.rootViewController = nav
        window?.makeKeyAndVisible()
        
        /*
         You can interact with the audio session throughout your app’s life cycle, but it’s often useful to perform this configuration at app launch
         */
        let audioSession = AVAudioSession.sharedInstance()
        do {
            // Set the audio session category, mode, and options.
            try audioSession.setCategory(.playback)
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
        
    }
    

    

}

