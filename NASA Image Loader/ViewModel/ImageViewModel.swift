//
//  ImageViewModel.swift
//  NASA Image Loader
//
//  Created by Shreekrishna on 23/11/22.
//

import Foundation
import UIKit

protocol ImageContentDelegate: AnyObject {
    func didReceiveImageContent()
    func didFailWithError(error: Error?)
}

// viewModel which has all the utilities required by viewcontroller.
class ImageViewModel {
    
    let serviceProvider: ImageProvider.Type
    var defaults: UserDefaults
    weak var delegate: ImageContentDelegate?
    private let calender = Calendar.current

    // injecting server properties. This is very usefull for end-end unit testing as we can injects mocks from here which preforms mock network calls
    init(serviceProvider: ImageProvider.Type = ImageServiceProvider.self, defaults: UserDefaults = UserDefaults.standard) {
        self.serviceProvider = serviceProvider
        self.defaults = defaults
    }
    
    // base URL for network call
    var imageUrl: URL {
        return URL(string: "https://api.nasa.gov/planetary/apod?api_key=k8mTOseyTAgy9KOWMpAyea9vMg4tPU0HMXNwH45H")!
    }
    
    // first getting codable json response which has image URL and other stuff
    func getImageUrl() {
        serviceProvider.getImageUrl(from: imageUrl, success: { [weak self] response in
            guard let refreshRequired = self?.isRefreshRequired(), refreshRequired else {
                self?.delegate?.didReceiveImageContent()
                return
            }
            if let encoded = try? JSONEncoder().encode(response) {
                self?.defaults.set(encoded, forKey: "response")
            }
            if let urlString = response.url, let url = URL(string: urlString) {
                self?.getImageFromAPI(url: url)
            } else {
                self?.delegate?.didFailWithError(error: nil)
            }
        }, failure: { [weak self] error in
            self?.delegate?.didFailWithError(error: error)
        })
    }
    
    // Then getting the actual image from url from codable response
    private func getImageFromAPI(url: URL) {
        serviceProvider.downloadImage(from: url, success: { [weak self]  data, response in
            let imageName = "NASA.png"
            if let imageData = UIImage(data: data) {
                self?.defaults.set(Date(), forKey: "lastRefresh")
                self?.saveImageToDocumentDirectory(imageName: imageName, image: imageData)
                self?.delegate?.didReceiveImageContent()
            } else {
                self?.delegate?.didFailWithError(error: nil)
            }
        }, failure: { [weak self] error in
            self?.delegate?.didFailWithError(error: error)
        })
    }
    
    // saving file to document directory as we do not make api call on same day. This is the caching technique that being used to fetch images locally.
    func saveImageToDocumentDirectory(imageName: String, image: UIImage) {
        
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        let fileName = imageName
        let fileURL = documentsDirectory.appendingPathComponent(fileName)
        guard let data = image.jpegData(compressionQuality: 1) else { return }

        // Checks if file exists, removes it if so.
        if FileManager.default.fileExists(atPath: fileURL.path) {
            do {
                try FileManager.default.removeItem(atPath: fileURL.path)
                print("Removed old image")
            } catch let removeError {
                print("couldn't remove file at path", removeError)
            }
        }
        do {
            try data.write(to: fileURL)
        } catch let error {
            print("error saving file with error", error)
        }
    }
    
    // method for reading image from document directory
    func loadImageFromDiskWith(fileName: String) -> UIImage? {
        
      let documentDirectory = FileManager.SearchPathDirectory.documentDirectory
        let userDomainMask = FileManager.SearchPathDomainMask.userDomainMask
        let paths = NSSearchPathForDirectoriesInDomains(documentDirectory, userDomainMask, true)

        if let dirPath = paths.first {
            let imageUrl = URL(fileURLWithPath: dirPath).appendingPathComponent(fileName)
            let image = UIImage(contentsOfFile: imageUrl.path)
            return image
        }
        return nil
    }
    
    // storing codable response in userdefaults, if there is fresh api call and this variable will be overriden
    var response: ImageResponse? {
        guard let response = defaults.object(forKey: "response") as? Data else {
            return nil
        }
        let json = try? JSONDecoder().decode(ImageResponse.self, from: response)
        return json
    }
    
    // method to check if api call is required for the day. if user comes to app on same day then no need to make api call instead show cached image from document directory.
    private func isRefreshRequired() -> Bool {

        guard let lastRefreshDate = defaults.object(forKey: "lastRefresh") as? Date else {
            return true
        }
        if let diff = calender.dateComponents([.day], from: lastRefreshDate, to: Date()).day, diff >= 1 {
            return true
        } else {
            return false
        }
    }
}
