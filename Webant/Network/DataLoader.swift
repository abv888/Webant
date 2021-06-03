//
//  DataLoader.swift
//  Webant
//
//  Created by Bagrat Arutyunov on 30.05.2021.
//

import Foundation
import Alamofire
import AlamofireImage

class DataLoader {
    private init() {}
    
    static let shared: DataLoader = DataLoader()
    
    let data_url = "http://gallery.dev.webant.ru/api/photos?"
    let photos_url = "http://gallery.dev.webant.ru/media/"
    
    func loadNewPhotos(page: Int, result: @escaping ((RequestModel?)->())) {
        let requestParams: Parameters =  [
            "new": "true",
            "limit": "10",
            "page": page
        ]
        
        AF.request(data_url, method: .get, parameters: requestParams).responseDecodable(of: RequestModel.self) { response in
            result(response.value)
        }
    }
    
    func loadPopularPhotos(page: Int, result: @escaping ((RequestModel?)->())) {
        let requestParams: Parameters =  [
            "popular": "true",
            "limit": "10",
            "page": page
        ]
        
        AF.request(data_url, method: .get, parameters: requestParams).responseDecodable(of: RequestModel.self) { response in
            result(response.value)
        }
    }
}
