//
//  InterstitialViiew.swift
//  ImgurUploader
//
//  Created by Shun Sato on 2024/07/20.
//

import SwiftUI
import GoogleMobileAds

class InterstitialAd: NSObject, ObservableObject, GADFullScreenContentDelegate {
    @Published var interstitial: GADInterstitialAd?
    
    override init() {
        super.init()
        loadAd()
    }
    
    func loadAd() {
        Task {
            do {
                let loadedAd = try await GADInterstitialAd.load(
                    withAdUnitID: "ca-app-pub-8467408220599556/5275845231",
                    request: GADRequest()
                )
                DispatchQueue.main.async {
                    self.interstitial = loadedAd
                    print("Interstitial ad loaded successfully")
                }
            } catch {
                print("Failed to load interstitial ad with error: \(error.localizedDescription)")
            }
        }
    }
    
    func showAd(from rootViewController: UIViewController) {
        if let ad = interstitial {
            ad.fullScreenContentDelegate = self // デリゲート設定
            ad.present(fromRootViewController: rootViewController)
        } else {
            print("Ad wasn't ready")
            loadAd()
        }
    }
    
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        // 広告が閉じられたときの処理
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .interstitialAdDismissed, object: nil)
        }
    }
}

struct InterstitialAdView: UIViewControllerRepresentable {
    @Binding var isPresented: Bool
    let ad: InterstitialAd
    
    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        if isPresented {
            ad.showAd(from: uiViewController)
            isPresented = false
        }
    }
}

struct InterstitialAdViewModifier: ViewModifier {
    @StateObject var interstitialAd = InterstitialAd()
    @Binding var isPresented: Bool
    
    func body(content: Content) -> some View {
        content
            .background(
                InterstitialAdView(isPresented: $isPresented, ad: interstitialAd)
            )
    }
}

extension View {
    func interstitialAd(isPresented: Binding<Bool>) -> some View {
        self.modifier(InterstitialAdViewModifier(isPresented: isPresented))
    }
}

extension Notification.Name {
    static let interstitialAdDismissed = Notification.Name("interstitialAdDismissed")
}
