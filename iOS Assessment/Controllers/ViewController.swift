//
//  ViewController.swift
//  iOS Assessment
//
//  Created by Faisal Feroz on 21/12/2023.
//

import UIKit
import PhotosUI

class ViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var photosCollectionView: UICollectionView!
    @IBOutlet weak var addButton: UIButton!
    var activityIndicator: UIActivityIndicatorView!

    // MARK: - Properties
    var imageArray = [UIImage]()

    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupActivityIndicator()
        loadImagesFromDocumentsDirectory()
    }

    // MARK: - IBActions
    @IBAction func addPhotoButtonTapped(_ sender: UIBarButtonItem) {
        showImageSourceOptions()
    }

    // MARK: - Private Methods

    /// Displays an alert with options to open the camera or choose from the photo library.
    private func showImageSourceOptions() {
        let alertController = UIAlertController(title: StringConstants.ViewController.AlertControllerTitle, message: StringConstants.ViewController.AlertControllerMessage, preferredStyle: .actionSheet)

        let openCameraAction = UIAlertAction(title: StringConstants.ViewController.TakePhoto, style: .default) { [weak self] _ in
            self?.openCamera()
        }

        let openLibraryAction = UIAlertAction(title: StringConstants.ViewController.ChoosePhoto, style: .default) { [weak self] _ in
            self?.openPhotoLibrary()
        }

        let cancelAction = UIAlertAction(title: StringConstants.ViewController.Cancel, style: .cancel, handler: nil)

        alertController.addAction(openCameraAction)
        alertController.addAction(openLibraryAction)
        alertController.addAction(cancelAction)

        if let popoverController = alertController.popoverPresentationController {
            popoverController.sourceView = addButton
            popoverController.sourceRect = addButton.bounds
        }

        present(alertController, animated: true, completion: nil)
    }

    /// Opens the device camera to capture a photo.
    private func openCamera() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .camera
            present(imagePicker, animated: true)
        } else {
            showAlert(message: StringConstants.ViewController.AlertMessage)
        }
    }

    /// Opens the photo library to choose images.
    private func openPhotoLibrary() {
        var config = PHPickerConfiguration()
        config.selectionLimit = 0

        let phPickerVC = PHPickerViewController(configuration: config)
        phPickerVC.delegate = self
        present(phPickerVC, animated: true)
    }

    /// Displays a simple alert with a message.
    private func showAlert(message: String) {
        let alert = UIAlertController(title: StringConstants.ViewController.Alert, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: StringConstants.ViewController.OK, style: .default, handler: nil))
        present(alert, animated: true)
    }
    /// Show the activityIndicator
    private func setupActivityIndicator() {
        activityIndicator = UIActivityIndicatorView(style: .medium)
        activityIndicator.color = .red
        activityIndicator.center = view.center
        activityIndicator.hidesWhenStopped = true
        view.addSubview(activityIndicator)
    }

}
