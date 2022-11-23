//
//  ViewController.swift
//  NASA Image Loader
//
//  Created by Shreekrishna on 23/11/22.
//

import UIKit

class LaunchViewController: UIViewController {

    @IBOutlet var seeMeButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func seeMeButtonTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(identifier: "imageViewController", creator: { coder in
            return ImageViewController(coder: coder, viewModel: ImageViewModel())
        })
        navigationController?.pushViewController(viewController, animated: true)
    }
}

