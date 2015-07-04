//
//  AppDelegate.swift
//  Bring the Food
//
//  Created by Stefano Bodini on 03/06/15.
//  Copyright (c) 2015 Federico Badini, Stefano Bodini. All rights reserved.
//

import UIKit
import GoogleMaps

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?

    // Observers
    weak var notificationObserver: NSObjectProtocol!
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        GMSServices.provideAPIKey(gMapsAPIKey)
        let settings = UIUserNotificationSettings(forTypes: UIUserNotificationType.Badge, categories: nil)
        UIApplication.sharedApplication().registerUserNotificationSettings(settings)
        // Get reference to storyboard
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if (RestInterface.getInstance().isLoggedIn()){
            let mainViewController = storyboard.instantiateViewControllerWithIdentifier("mainViewController") as? UIViewController
            if self.window != nil {
                self.window!.rootViewController = mainViewController
                notificationObserver = NSNotificationCenter.defaultCenter().addObserverForName(getNotificationsResponseNotificationKey,
                    object: ModelUpdater.getInstance(),
                    queue: NSOperationQueue.mainQueue(),
                    usingBlock: {(notification:NSNotification!) in self.handleNotifications(notification)})
                Model.getInstance().downloadMyNotifications()
            }
        }
        else
        {
            let loginController = storyboard.instantiateViewControllerWithIdentifier("LoginViewController") as! UIViewController
            if self.window != nil {
                self.window!.rootViewController = loginController
            }
        }
        return true
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        if(notificationObserver != nil){
            Model.getInstance().downloadMyNotifications()
        }
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(application: UIApplication) {
        if(notificationObserver != nil){
            NSNotificationCenter.defaultCenter().removeObserver(notificationObserver)
        }
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func handleNotifications(notification: NSNotification){
        let response = (notification.userInfo as! [String : HTTPResponseData])["info"]
        if(response?.status == RequestStatus.SUCCESS){
            let notifications = Model.getInstance().getMyNotifications()
            let prova = notifications.getNumberOfNewNotifications()
            let newNotifications = notifications.getNumberOfNewNotifications()
            let tabBarController = self.window!.rootViewController as! UITabBarController
            let badge = (tabBarController.tabBar.items as! [UITabBarItem])[3]
            if(newNotifications > 0){
                badge.badgeValue = String(notifications.getNumberOfNewNotifications())
                UIApplication.sharedApplication().applicationIconBadgeNumber = notifications.getNumberOfNewNotifications()
            }
            else{
                badge.badgeValue = nil
                UIApplication.sharedApplication().applicationIconBadgeNumber = 0
            }
        }
    }
    
    func removeNotificationObserver(){
        if(notificationObserver != nil){
            NSNotificationCenter.defaultCenter().removeObserver(notificationObserver)
            notificationObserver = nil
            UIApplication.sharedApplication().applicationIconBadgeNumber = 0
        }
    }
    
    func addNotificationObserver(){
        notificationObserver = NSNotificationCenter.defaultCenter().addObserverForName(getNotificationsResponseNotificationKey,
            object: ModelUpdater.getInstance(),
            queue: NSOperationQueue.mainQueue(),
            usingBlock: {(notification:NSNotification!) in self.handleNotifications(notification)})
        Model.getInstance().downloadMyNotifications()
    }
}