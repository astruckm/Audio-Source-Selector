//
//  AppDelegate.swift
//  Audio Source Selector
//
//  Created by Andrew Struck-Marcell on 10/30/18.
//  MIT License.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }

    func applicationWillTerminate(_ application: UIApplication) {
        //TODO: Code to add to UserDefaults
        let vc = ViewController()
        vc.output.text += "Table view is: " + vc.audioSourcesTableView.description
        vc.output.text += "# of Input audio sources: " + String(vc.inputAudioSources.count)
    }


}

