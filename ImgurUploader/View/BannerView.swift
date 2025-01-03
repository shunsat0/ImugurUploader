//
//  BannerView.swift
//  ImgurUploader
//
//  Created by Shun Sato on 2024/07/19.
//

import Foundation
import GoogleMobileAds
import UIKit
import SwiftUI

class ViewController: UIViewController {
    
    var bannerView: GADBannerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let viewWidth = view.frame.inset(by: view.safeAreaInsets).width
        
        let adaptiveSize = GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(viewWidth)
        bannerView = GADBannerView(adSize: adaptiveSize)
        
        addBannerViewToView(bannerView)
        
        bannerView.adUnitID = "ca-app-pub-8467408220599556/3245374427"
        bannerView.rootViewController = self
        
        bannerView.load(GADRequest())
    }
    
    func addBannerViewToView(_ bannerView: GADBannerView) {
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bannerView)
        view.addConstraints(
            [NSLayoutConstraint(item: bannerView,
                                attribute: .bottom,
                                relatedBy: .equal,
                                toItem: view.safeAreaLayoutGuide,
                                attribute: .bottom,
                                multiplier: 1,
                                constant: 0),
             NSLayoutConstraint(item: bannerView,
                                attribute: .centerX,
                                relatedBy: .equal,
                                toItem: view,
                                attribute: .centerX,
                                multiplier: 1,
                                constant: 0)
            ])
    }
    
}


struct GADBannerViewController: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        let view = GADBannerView(adSize: GADAdSizeBanner)
        let viewController = UIViewController()
        view.adUnitID = "ca-app-pub-8467408220599556/3245374427"
        view.rootViewController = viewController
        viewController.view.addSubview(view)
        viewController.view.frame = CGRect(origin: .zero, size: GADAdSizeBanner.size)
        view.load(GADRequest())
        return viewController
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}


struct BannerAd: View {
    var body: some View {
        GADBannerViewController()
            .frame(width: GADAdSizeBanner.size.width, height: GADAdSizeBanner.size.height)
    }
}

#Preview {
    BannerAd()
}
