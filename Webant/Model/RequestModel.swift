//
//  RequestModel.swift
//  Webant
//
//  Created by Bagrat Arutyunov on 30.05.2021.
//

import Foundation


struct RequestModel: Codable {
    
    var data: [DataModel]?
    var countOfPages: Int?
    
}

struct DataModel: Codable {
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case name = "name"
        case dateCreate = "dateCreate"
        case descr = "description"
        case new = "new"
        case popular = "popular"
        case image = "image"
        case user = "user"
    }
    
    var id: Int?
    var name: String?
    var dateCreate: String?
    var descr: String?
    var new: Bool?
    var popular: Bool?
    var image: ImageModel?
    var user: String?
    
}

struct ImageModel: Codable {
    
    var id: Int?
    var name: String?
    
}

struct ImageRequestModel: Codable {
    
    var file: String?
    var id: Int?
    var name: String?
    
}
