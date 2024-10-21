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
import AppTrackingTransparency
import AdSupport
import SwiftyDropbox

class AppDelegate: NSObject, UIApplicationDelegate {
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        FirebaseApp.configure()
        
        // iOS 14以降の場合、ATTリクエストを遅延実行
        if #available(iOS 14, *) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.requestIDFA()
            }
        } else {
            // iOS 14未満の場合は直接AdMobを初期化
            self.initializeAdMob()
        }
        
        return true
    }
    
    @available(iOS 14, *)
    func requestIDFA() {
        ATTrackingManager.requestTrackingAuthorization { status in
            DispatchQueue.main.async {
                switch status {
                case .authorized, .denied, .restricted, .notDetermined:
                    // どの状態でもAdMobを初期化します
                    self.initializeAdMob()
                @unknown default:
                    break
                }
            }
        }
    }
    
    func initializeAdMob() {
        GADMobileAds.sharedInstance().start(completionHandler: nil)
    }
}

@main
struct ImgurUploaderApp: App {
    init() {
        if let apiKey = Bundle.main.object(forInfoDictionaryKey: "DROPBOX_API_KEY") as? String {
            DropboxClientsManager.setupWithAppKey(apiKey)
        }
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
