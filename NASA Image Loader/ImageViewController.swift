//
//  ImageViewController.swift
//  NASA Image Loader
//
//  Created by Shreekrishna on 23/11/22.
//

import UIKit

class ImageViewController: UIViewController {

    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    var viewModel: ImageViewModel
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet var descriptionLabel: UILabel!
    
    // injecting all dependencies via viewModel. ViewModel contains the network call to be made and notify viewcontroller via delegates.
    
    init?(coder: NSCoder, viewModel: ImageViewModel) {
        self.viewModel = viewModel
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // show activity indicator for first time once data comes hide that and show actual results
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator.startAnimating()
        viewModel.delegate = self
        viewModel.getImageUrl()
        activityIndicator.startAnimating()
        navigationItem.title = ""
        showImage()
    }
}

extension ImageViewController: ImageContentDelegate {
    
    // delegate methods which notify viewcontrollers once response is recieved
    func didReceiveImageContent() {
        DispatchQueue.main.async {
            self.showImage()
        }
    }
    
    private func showImage() {
        if let image = viewModel.loadImageFromDiskWith(fileName: "NASA.png"), let response = viewModel.response {
            imageView.image = image
            imageView.contentMode = .scaleAspectFill
            descriptionLabel.text = response.explanation
            navigationItem.title = response.title
            activityIndicator.stopAnimating()
            activityIndicator.isHidden = true
        }
    }
    
    // if response does not come then show alert with appropriate error message
    func didFailWithError(error: Error?) {
        var headerMessage = ""
        var detailMessage = ""
        if let error = error as? URLError, error.code == .notConnectedToInternet {
            headerMessage = "No internet Connection"
            detailMessage = "We are not connected to internet, showing u the last image we have."
        } else {
            headerMessage = "Something unexpected happened"
            detailMessage = "Hey, dont worry, please try again"
        }
        showAlert(headerMessage: headerMessage, detailMessage: detailMessage)
    }
    
    // showing alert on main thread as we are updating UI from backend
    private func showAlert(headerMessage: String, detailMessage: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: headerMessage, message: detailMessage,  preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: { _ in
                self.activityIndicator.stopAnimating()
                self.activityIndicator.isHidden = true
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
}
