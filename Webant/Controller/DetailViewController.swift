//
//  DetailViewController.swift
//  Webant
//
//  Created by Bagrat Arutyunov on 29.05.2021.
//

import UIKit
import AlamofireImage
import Alamofire

class DetailViewController: UIViewController {
    
    @IBOutlet weak var detailStackView: UIStackView!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var fullImageView: UIImageView!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var textLabel: UILabel!
    
    var titleLabelText: String?
    var textLabelText: String?
    var image = UIImage()
    var imageRequestString: String?
    var inputData: DetailControllerInput?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.tintColor = .systemPink
        setupScrollView()
        setupData()
    }
    
    private func setupScrollView() {
        scrollView.frame.size.width = view.frame.size.width
        scrollView.frame.size.height = contentView.frame.size.height
    }
    
    func setupDataInController(inputData: DetailControllerInput) {
        self.inputData = inputData
    }
    
    private func setupData() {
        fullImageView.contentMode = .scaleAspectFit
        if let requestString = inputData?.imageRequestString, let requestUrl = URL(string: requestString) {
            fullImageView.af.setImage(withURL: requestUrl)
        } else {
            fullImageView.image = UIImage(named: "NoInternet")
        }
        titleLabel.text = inputData?.titleLabelText
        textLabel.text = inputData?.textLabelText
    }
    
}
