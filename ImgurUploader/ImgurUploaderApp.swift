//
//  ImgurUploaderApp.swift
//  ImgurUploader
//
//  Created by Shun Sato on 2024/01/07.
//

import SwiftUI
import SwiftData
import GoogleMobileAds
import Firebase


class AppDelegate: UIResponder, UIApplicationDelegate {
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        
        FirebaseApp.configure()
        
        return true
    }
}


@main
struct ImgurUploaderApp: App {
    init() {
        UIPageControl.appearance().currentPageIndicatorTintColor = UIColor.systemBlue
        
        UIPageControl.appearance().pageIndicatorTintColor = UIColor.systemGray
    }
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(for: ImageData.self)
        }
    }
}
