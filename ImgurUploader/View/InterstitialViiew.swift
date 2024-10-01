//
//  InterstitialViiew.swift
//  ImgurUploader
//
//  Created by Shun Sato on 2024/07/20.
//

import SwiftUI
import GoogleMobileAds

class InterstitialAd: NSObject, ObservableObject {
    @Published var interstitial: GADInterstitialAd?
    
    override init() {
        super.init()
        loadAd()
    }
    
    func loadAd() {
        Task {
            do {
                interstitial = try await GADInterstitialAd.load(
                    withAdUnitID: "ca-app-pub-8467408220599556/5275845231",
                    request: GADRequest()
                )
                print("Interstitial ad loaded successfully")
            } catch {
                print("Failed to load interstitial ad with error: \(error.localizedDescription)")
            }
        }
    }
    
    func showAd(from rootViewController: UIViewController) {
        if let ad = interstitial {
            ad.present(fromRootViewController: rootViewController)
        } else {
            print("Ad wasn't ready")
            loadAd()
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
