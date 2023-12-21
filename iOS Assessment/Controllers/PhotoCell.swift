//
//  PhotoCell.swift
//  iOS Assessment
//
//  Created by Faisal Feroz on 21/12/2023.
//

import UIKit

class PhotoCell: UICollectionViewCell {
    
    @IBOutlet weak var photoImageView: UIImageView!
    
    func addTapGesture(target: Any, action: Selector) {
           let tapGesture = UITapGestureRecognizer(target: target, action: action)
           photoImageView.isUserInteractionEnabled = true
           photoImageView.addGestureRecognizer(tapGesture)
       }
}
