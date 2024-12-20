//
//  ListTableViewCell.swift
//  Assesment
//
//  Created by Edevane Tan on 19/12/2024.
//

import UIKit

class ListCollectionViewCell: UICollectionViewCell {

    static let cellIdentifier = "listCell"

    @IBOutlet weak var animalImageView: UIImageView!
    @IBOutlet weak var verticalStackView: UIStackView!

    override func awakeFromNib() { // swiftlint:disable:this unneeded_override
        super.awakeFromNib()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.animalImageView.image = nil
        for item in verticalStackView.arrangedSubviews {
            self.verticalStackView.removeArrangedSubview(item)
            item.removeFromSuperview()
        }
    }

    public func setupCell(with data: Animal) {
        self.setupLabels(with: data)
        self.animalImageView.backgroundColor = .gray
        if let image = data.image {
            self.setupImage(with: image)
        } else {
            if let id = data.referencePhotoID {
                Task {
                    if let fetchData = try await NetworkManager.fetchImage(of: id) {
                        self.setupImage(with: fetchData)
                    }
                }
            }
        }
    }

    private func setupImage(with data: Data) {
        let image = UIImage(data: data)
        self.animalImageView.image = image
    }

    private func setupLabels(with data: Animal) {
        let breedNameLabel = UILabel()
        breedNameLabel.text = data.name
        breedNameLabel.font = UIFont.boldSystemFont(ofSize: 16.0)

        let breedDescription = UILabel()
        breedDescription.text = data.breedDescription

        self.verticalStackView.addArrangedSubview(breedNameLabel)
        self.verticalStackView.addArrangedSubview(breedDescription)
    }
}
