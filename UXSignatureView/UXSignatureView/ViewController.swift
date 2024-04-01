//
//  ViewController.swift
//  UXSignatureView
//
//  Created by Deepak Goyal on 11/03/24.
//

import UIKit
import CryptoKit

class ViewController: UIViewController {

    @IBOutlet weak var signImage: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func addSignatureAction(_ sender: Any) {
        
        let viewController = UXSignatureViewController()
        viewController.delegate = self
        viewController.watermark = UIImage(named: "watermark _pp")
        viewController.canvasSize = .fixed(width: 350, height: 350)
        viewController.capturedImageSize = .fixed(width: 25, height: 25)
        viewController.modalPresentationStyle = .fullScreen
        (viewController.presentationController as?
                 UISheetPresentationController)?.prefersGrabberVisible = true
        self.present(viewController, animated: true)
    }
    
}
extension ViewController : UXSignatureViewControllerDelegate{
    
    func didTapCapture(onViewController controller: UIViewController, image: UIImage) {
        
        signImage.image = image
        DispatchQueue(label: "size", qos: .userInteractive).async {
            guard let data = image.jpegData(compressionQuality: 1) else { return }
            print("SIZE OF - \(data.count)")
        }
    }
    
    func didTapCross(onViewController controller: UIViewController) {
        controller.dismiss(animated: true)
    }
}
