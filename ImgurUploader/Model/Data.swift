//
//  Data.swift
//  ImgurUploader
//
//  Created by Shun Sato on 2024/06/01.
//

import Foundation
import SwiftData

@Model
class ImageData {
    var url: String
    var deletehas: String
    
    init(url: String, deletehas: String) {
        self.url = url
        self.deletehas = deletehas
    }
}
