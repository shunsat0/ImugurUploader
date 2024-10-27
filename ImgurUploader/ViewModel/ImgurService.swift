//
//  PostImage.swift
//  ImgurUploader
//
//  Created by Shun Sato on 2024/05/19.
//
import Foundation
import Alamofire
import SwiftUI
import Combine
import FirebaseCrashlytics

final class ImgurDataViewModel: ObservableObject {
    
    @Published var postedImageData: ImgurDataModel?
    @Published var errorMessage: String?
    @Published var isUploading: Bool = false
    @Published var isShowSheet: Bool = false
    @Published var isShowIntersitalAd: Bool = false
    
    func postImage(image: UIImage) async {
        let url  = "https://api.imgur.com/3/image"
        let clientId = "d6ee7fa84ca8bd2"
        
        guard let imageData = image.jpegData(compressionQuality: 1.0) else {
            print("Failed to convert image to data")
            Crashlytics.crashlytics().setCustomValue("Failed to convert image to data", forKey: "ImageUploadError")
            return
        }
        
        let headers: HTTPHeaders = [
            "Authorization": "Client-ID \(clientId)"
        ]
        
        // アップロード開始時のログ
        Crashlytics.crashlytics().log("Starting image upload")
        Crashlytics.crashlytics().setCustomValue(url, forKey: "UploadURL")
        Crashlytics.crashlytics().setCustomValue(imageData.count, forKey: "ImageSizeBytes")
        
        DispatchQueue.main.async {
            self.isUploading = true
            self.isShowSheet = false
        }
        
        AF.upload(
            multipartFormData: { multipartFormData in
                multipartFormData.append(imageData, withName: "image")
            },
            to: url,
            headers: headers
        ).responseData { response in
            //TODO: 確実にアップロードが終わるまでローディング表示→広告表示になっているか確認
            DispatchQueue.main.async {
                self.isUploading = false
            }
            
            self.isShowIntersitalAd = true
            
            guard let data = response.data else {
                Crashlytics.crashlytics().setCustomValue("No response data", forKey: "ImageUploadError")
                return
            }
            
            do {
                let imgurDataModel: ImgurDataModel = try JSONDecoder().decode(ImgurDataModel.self, from: data)
                let link = imgurDataModel.data.link
                let deletehash = imgurDataModel.data.deletehash
                
                print(link)
                print(deletehash)
                
                // アップロード成功時のログ
                Crashlytics.crashlytics().log("Image upload successful")
                Crashlytics.crashlytics().setCustomValue(link, forKey: "UploadedImageLink")
                Crashlytics.crashlytics().setCustomValue(deletehash, forKey: "DeleteHash")
                
                let model = ImgurDataModel(data: DataInfoModel(link: link, deletehash: deletehash))
                
                DispatchQueue.main.async {
                    self.postedImageData = model
                }
                
                NotificationCenter.default.addObserver(forName: .interstitialAdDismissed, object: nil, queue: .main) { _ in
                    self.isShowSheet = true
                }
                
            } catch {
                print("Failed to decode response: \(error)")
                // デコードエラー時のログ
                Crashlytics.crashlytics().setCustomValue("Failed to decode response", forKey: "ImageUploadError")
                Crashlytics.crashlytics().record(error: error)
            }
        }
        
    }
    
    func delete(hashcode: String) async throws -> String {
        // 削除処理開始時のログ
        Crashlytics.crashlytics().log("Starting image delete")
        Crashlytics.crashlytics().setCustomValue(hashcode, forKey: "DeleteHashcode")
        
        let url = URL(string: "https://api.imgur.com/3/image/\(hashcode)")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.addValue("Client-ID d6ee7fa84ca8bd2", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            Crashlytics.crashlytics().setCustomValue("Bad server response", forKey: "ImageDeleteError")
            throw URLError(.badServerResponse)
        }
        
        guard httpResponse.statusCode == 200 else {
            Crashlytics.crashlytics().setCustomValue("HTTP status: \(httpResponse.statusCode)", forKey: "ImageDeleteError")
            throw URLError(.badServerResponse)
        }
        
        // 削除成功時のログ
        Crashlytics.crashlytics().log("Image delete successful")
        
        return String(data: data, encoding: .utf8) ?? "No response body"
    }
}
