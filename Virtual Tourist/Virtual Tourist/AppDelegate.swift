//
//  AppDelegate.swift
//  Virtual Tourist
//
//  Created by Nouf Abdullah on 5/14/19.
//  Copyright © 2019 Nouf Abdullah. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
 
    let dataControllers = DataControllers(modelName: "LocationsModel")
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        dataControllers.load()
        let navigationController = window?.rootViewController as! UINavigationController
        let mapView = navigationController.topViewController as! MapViewController
        mapView.dataControllers = dataControllers
        return true
    }
}

