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

    
    func postImage(image: UIImage) {
        let url  = "https://api.imgur.com/3/image"
        let clientId = "d6ee7fa84ca8bd2"
        
        guard let imageData = image.jpegData(compressionQuality: 1.0) else {
            print("Failed to convert image to data")
            return
        }
        
        let headers: HTTPHeaders = [
            "Authorization": "Client-ID \(clientId)"
        ]
        
        AF.upload(
            multipartFormData: { multipartFormData in
                multipartFormData.append(imageData, withName: "image")
            },
            to: url,
            headers: headers
        ).responseData { response in
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
}
