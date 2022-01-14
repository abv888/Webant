//
//  ImageCollectionViewCell.swift
//  Webant
//
//  Created by Bagrat Arutyunov on 29.05.2021.
//

import UIKit
import Kingfisher

class ImageCollectionViewCell: UICollectionViewCell {
    static let reuseIdentifier = "ImageCell"
    
    @IBOutlet weak var imageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.masksToBounds = false
        clipsToBounds = false
        layer.cornerRadius = 10
        layer.shadowOpacity = 1
        layer.shadowRadius = 6
        layer.shadowOffset = CGSize(width: 0, height: 4)
        layer.shadowColor = UIColor.black.cgColor
        layer.borderWidth = 0.5
        layer.borderColor = UIColor.black.cgColor
        imageView.layer.cornerRadius = 10
    }
    
    override func prepareForReuse() {
        super .prepareForReuse()
        imageView.kf.cancelDownloadTask()
        imageView.image = nil
    }
    
}
