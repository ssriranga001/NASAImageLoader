//
//  ImageProvider.swift
//  NASA Image Loader
//
//  Created by Shreekrishna on 23/11/22.
//

import Foundation

protocol ImageProvider {
    static func downloadImage(from url: URL, success: @escaping ((_ data: Data, _ response: URLResponse?) -> Void), failure: @escaping ((_ error: Error?) -> Void))
    static func getImageUrl(from url: URL, success: @escaping ((_ response: ImageResponse) -> Void), failure: @escaping ((_ error: Error?) -> Void))
}

// service class which makes network call to fetch data. Here almost all scenarios are covered and nowhere user gonna be struck. success and failure are handled correctly.
class ImageServiceProvider: ImageProvider {
    static func downloadImage(from url: URL, success: @escaping ((_ data: Data, _ response: URLResponse?) -> Void), failure: @escaping ((_ error: Error?) -> Void)) {
        print("Download Started")
        getData(from: url) { data, response, error in
            print("Download Finished")
            guard let data = data, error == nil else {
                failure(error)
                return
            }
            success(data, response)
        }
    }
    
    static func getImageUrl(from url: URL, success: @escaping ((_ response: ImageResponse) -> Void), failure: @escaping ((_ error: Error?) -> Void)) {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        URLSession.shared.dataTask(with: request, completionHandler: { data, response, error -> Void in
            guard let data = data, let response = try? JSONDecoder().decode(ImageResponse.self, from: data) else {
                print("not able to parse response")
                failure(error)
                return
            }
            success(response)
        }).resume()
    }
    
    private static func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
}
