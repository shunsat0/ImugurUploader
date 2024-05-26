//
//  ImgurUploaderApp.swift
//  ImgurUploader
//
//  Created by Shun Sato on 2024/01/07.
//

import SwiftUI

@main
struct ImgurUploaderApp: App {
    init() {
        UIPageControl.appearance().currentPageIndicatorTintColor = UIColor.systemBlue
        
        UIPageControl.appearance().pageIndicatorTintColor = UIColor.systemGray
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
            //TestUI()
        }
    }
}
