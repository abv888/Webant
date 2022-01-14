//
//  DataLoader.swift
//  Webant
//
//  Created by Bagrat Arutyunov on 30.05.2021.
//

import Foundation
import Alamofire
import RxSwift
import RxAlamofire

class DataLoader {
    private init() {}
    
    static let shared: DataLoader = DataLoader()
    
    let dataUrl = "http://gallery.dev.webant.ru/api/photos?"
    let photosUrl = "http://gallery.dev.webant.ru/media/"
    
    public var errorNew: Error?
    public var errorPop: Error?

    private let disposeBagNew = DisposeBag()
    private let disposeBagPop = DisposeBag()
    
    public func loadNew(page: Int, result: @escaping ((RequestModel?)->())) {
        let requestParams: Parameters =  [
            "new": "true",
            "limit": "10",
            "page": page
        ]
        RxAlamofire.requestJSON(.get, dataUrl, parameters: requestParams)
            .subscribe(onNext: {(response, any) in
            if 200..<300 ~= response.statusCode {
                do {
                    let data = try JSONSerialization.data(withJSONObject: any)
                    let newPhotos = try JSONDecoder().decode(RequestModel.self, from: data)
                    result(newPhotos)
                } catch let error {
                    self.errorNew = error
                }
            }
            }).disposed(by: disposeBagNew)

    }
    
    public func loadPop(page: Int, result: @escaping ((RequestModel?)->())) {
        let requestParams: Parameters =  [
            "popular": "true",
            "limit": "10",
            "page": page
        ]
        RxAlamofire.requestJSON(.get, dataUrl, parameters: requestParams).subscribe(onNext: {(response, any) in
            if 200..<300 ~= response.statusCode {
                do {
                    let data = try JSONSerialization.data(withJSONObject: any)
                    let popPhotos = try JSONDecoder().decode(RequestModel.self, from: data)
                    result(popPhotos)
                } catch let error {
                    self.errorNew = error
                }
            }
        }).disposed(by: disposeBagPop)

    }
    

    
    
    

}
