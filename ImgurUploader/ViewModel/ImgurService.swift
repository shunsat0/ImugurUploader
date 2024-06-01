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


final class ImgurDataViewModel: ObservableObject {
    
    @Published var postedImageData: ImgurDataModel?
    @Published var errorMessage: String?
    @Published var isUploading: Bool = false
    @Published var isShowSheet: Bool = false

    func postImage(image: UIImage) async {
        let url  = "https://api.imgur.com/3/image"
        let clientId = "d6ee7fa84ca8bd2"
        
        guard let imageData = image.jpegData(compressionQuality: 1.0) else {
            print("Failed to convert image to data")
            return
        }
        
        let headers: HTTPHeaders = [
            "Authorization": "Client-ID \(clientId)"
        ]
        
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
            DispatchQueue.main.async {
                self.isUploading = false
                self.isShowSheet = true
            }

            guard let data  = response.data else { return }
            
            do {
                let imgurDataModel: ImgurDataModel = try JSONDecoder().decode(ImgurDataModel.self, from: data)
                let link = imgurDataModel.data.link
                let deletehash = imgurDataModel.data.deletehash
                
                print(link)
                print(deletehash)
                
                let model = ImgurDataModel(data: DataInfoModel(link: link, deletehash: deletehash))
                
                DispatchQueue.main.async {
                    self.postedImageData = model
                }
                                            
            } catch {
                print("Failed to decode response: \(error)")
            }
        }
    }
    
    func delete(hashcode: String) async throws -> String {
        let url = URL(string: "https://api.imgur.com/3/image/\(hashcode)")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.addValue("Client-ID d6ee7fa84ca8bd2", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        guard httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        return String(data: data, encoding: .utf8) ?? "No response body"
    }
}
