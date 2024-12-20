//
//  FeaturedTableViewCell.swift
//  Assesment
//
//  Created by Edevane Tan on 19/12/2024.
//

import UIKit

class FeaturedCollectionViewCell: UICollectionViewCell {

    static let cellIdentifier = "featuredCell"

    @IBOutlet weak var catImageView: UIImageView!
    @IBOutlet weak var catBreedLabel: UILabel!

    override func awakeFromNib() { // swiftlint:disable:this unneeded_override
        super.awakeFromNib()
    }

    override func prepareForReuse() {
        self.catImageView.image = nil
    }

    func setupCell(with data: Animal) {
        self.catBreedLabel.text = data.name
        if let imageData = data.image {
            self.catImageView.image = UIImage(data: imageData)
            catImageView.layer.cornerRadius = 12.0
            catImageView.layer.masksToBounds = true
        }
    }
}
