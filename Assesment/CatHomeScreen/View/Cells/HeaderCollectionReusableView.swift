//
//  HeaderCollectionReusableView.swift
//  Assesment
//
//  Created by Edevane Tan on 20/12/2024.
//

import UIKit

class HeaderCollectionReusableView: UICollectionReusableView {
    static let reuseIdentifier = "headerCell"

    var label: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 24.0)
        label.textAlignment = .left
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureHeader()
    }

    required init?(coder: NSCoder) {
        fatalError("Not implemented")
    }

    func configureHeader() {
        label.translatesAutoresizingMaskIntoConstraints = false
        addSubview(label)
        label.topAnchor.constraint(equalTo: topAnchor).isActive = true
        label.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        label.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
    }
}
