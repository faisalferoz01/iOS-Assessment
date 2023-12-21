//
//  ViewControllerExtension.swift
//  iOS Assessment
//
//  Created by Faisal Feroz on 22/12/2023.
//

import UIKit
import PhotosUI

// MARK: - UICollectionViewDataSource
extension ViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        imageArray.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: StringConstants.ViewController.PhotoCell, for: indexPath) as? PhotoCell else {
            return UICollectionViewCell()
        }

        // Set the size of the photoImageView
        let desiredSize = CGSize(width: cell.frame.size.width, height: cell.frame.size.height)
        cell.photoImageView.frame.size = desiredSize
        cell.photoImageView.contentMode = .scaleAspectFill
        cell.photoImageView.clipsToBounds = true

        // Set the image
        cell.photoImageView.image = imageArray[indexPath.row]

        // Add tap gesture to open full-screen view
        cell.addTapGesture(target: self, action: #selector(imageTapped(_:)))

        return cell
    }

       // Handle tap on an image
       @objc func imageTapped(_ gesture: UITapGestureRecognizer) {
           guard let tappedImageView = gesture.view as? UIImageView else {
               return
           }

           // Get the index of the tapped image
           if let index = imageArray.firstIndex(of: tappedImageView.image ?? UIImage()) {
               showFullScreenImage(at: index)
           }
       }

       // Show full-screen image
       func showFullScreenImage(at index: Int) {
           let fullScreenVC = ImagePreviewViewController()
           fullScreenVC.image = imageArray[index]
           present(fullScreenVC, animated: true, completion: nil)
       }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension ViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.size.width / 4, height: collectionView.frame.size.height / 6)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        0
    }
}

// MARK: - PHPickerViewControllerDelegate
extension ViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        dismiss(animated: true)
        activityIndicator.startAnimating()

        let dispatchGroup = DispatchGroup()

        for result in results {
            dispatchGroup.enter()
            result.itemProvider.loadObject(ofClass: UIImage.self) { object, error in
                defer {
                    dispatchGroup.leave()
                }
                if let image = object as? UIImage {
                    self.imageArray.append(image)
                    self.saveImagesToDocumentsDirectory()
                }
            }
        }

        dispatchGroup.notify(queue: .main) {
            self.activityIndicator.stopAnimating()
            self.photosCollectionView.reloadData()
        }
    }
}

// MARK: - UIImagePickerControllerDelegate
extension ViewController: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            imageArray.append(image)
            photosCollectionView.reloadData()
        }
        picker.dismiss(animated: true, completion: nil)
    }
}

// MARK: - Image File Management
extension ViewController {
    // Save images to Documents directory
    func saveImagesToDocumentsDirectory() {
        let fileManager = FileManager.default
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let imagesDirectory = documentsDirectory.appendingPathComponent(StringConstants.ViewController.Images)

        do {
            try fileManager.createDirectory(at: imagesDirectory, withIntermediateDirectories: true, attributes: nil)

            for (index, image) in imageArray.enumerated() {
                let fileName = "image_\(index).png"
                let fileURL = imagesDirectory.appendingPathComponent(fileName)
                if let imageData = image.pngData() {
                    try imageData.write(to: fileURL)
                }
            }
        } catch {
            print("\(error)")
        }
    }

    // Load images from Documents directory
    func loadImagesFromDocumentsDirectory() {
        let fileManager = FileManager.default
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let imagesDirectory = documentsDirectory.appendingPathComponent(StringConstants.ViewController.Images)

        do {
            let fileURLs = try fileManager.contentsOfDirectory(at: imagesDirectory, includingPropertiesForKeys: nil)
            for fileURL in fileURLs {
                if let imageData = try? Data(contentsOf: fileURL), let image = UIImage(data: imageData) {
                    imageArray.append(image)
                }
            }
        } catch {
            print("\(error)")
        }
    }
}
