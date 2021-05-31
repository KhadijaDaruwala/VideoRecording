//
//  ViewController.swift
//  VideoRecordingDemo
//
//  Created by Khadija Daruwala on 10/08/20.
//  Copyright © 2020 Khadija Daruwala. All rights reserved.
//

import UIKit
import MobileCoreServices
import AVFoundation

class RecordViewController: UIViewController {
    @IBOutlet weak var imagePreview: UIImageView!
    
    // Class Properties
    let imagePicker = UIImagePickerController()
    var cameraOverlay =  RecordView()
    var isVideoRecording = false
    var timer = Timer()
    var startTime = Date()
    var isPhotoCapture = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePreview.isHidden = true
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(_:)))
        imagePreview.isUserInteractionEnabled = true
        imagePreview.addGestureRecognizer(tapGestureRecognizer)
        
    }
}

//MARK: Button Actions
extension RecordViewController {
    @IBAction func buttonRecordVideoClicked(_ sender: Any) {
        isPhotoCapture = false
        setUpCameraOverlay()
        if !checkCameraAccess(){
            return
        }
        if(UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera)) {
            imagePicker.delegate = self
            imagePicker.sourceType = .camera
            imagePicker.mediaTypes = [kUTTypeMovie as String]
            imagePicker.allowsEditing = true
            imagePicker.cameraOverlayView = cameraOverlay
            imagePicker.showsCameraControls = false
            imagePicker.cameraFlashMode = .off
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    
    
    @IBAction func buttonCaptureImageClicked(_ sender: Any) {
        isPhotoCapture = true
        setUpCameraOverlay()
        if !checkCameraAccess(){
            return
        }
        if(UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera)) {
            imagePicker.delegate = self
            imagePicker.sourceType = .camera
            imagePicker.cameraCaptureMode = .photo
            imagePicker.showsCameraControls = false
            
            //                let screenBounds: CGSize = UIScreen.main.bounds.size;
            //
            //                let scale = screenBounds.height / screenBounds.width;
            //
            //                imagePicker.cameraViewTransform = imagePicker.cameraViewTransform.scaledBy(x: scale, y: scale);
            
            //                        let cameraTransform = CGAffineTransform(scaleX: 1.23, y: 1.23)
            //                        imagePicker.cameraViewTransform = cameraTransform
            
            
            //            let screenSize = UIScreen.main.bounds.size
            //            let aspectRatio:CGFloat = 3/4
            //            let scale = screenSize.height/screenSize.width * aspectRatio
            //            imagePicker.cameraViewTransform = CGAffineTransform(scaleX: scale, y: scale);
            
            
            
            //            let bounds  = UIScreen.main.bounds
            //            cameraOverlay.center = CGPoint(x: bounds.midX, y: bounds.midY)
            //            cameraOverlay.bounds = bounds
            //            self.imagePicker.cameraOverlayView = cameraOverlay
            
            
            
            imagePicker.cameraOverlayView = cameraOverlay
            
            let translate = CGAffineTransform(translationX: 0.0, y: 71.0) //This slots the preview exactly in the middle of the screen by moving it down 71 points
            imagePicker.cameraViewTransform = translate
            
            let scale = translate.scaledBy(x: 1.333333, y: 1.333333)
            imagePicker.cameraViewTransform = scale
            
            cameraOverlay.labelTimer.isHidden = true
            
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    @objc func startStopRecordingClicked(){
        if isPhotoCapture{
            imagePicker.takePicture()
            
        } else {
            isVideoRecording = !isVideoRecording
            resetTimer()
            cameraOverlay.setRecordingView(isRecording: isVideoRecording)
            if isVideoRecording {
                imagePicker.startVideoCapture()
                timer = Timer.scheduledTimer(timeInterval: 1.0,
                                             target: self,
                                             selector: #selector(setTimer),
                                             userInfo: nil,
                                             repeats: true)
                
            } else{
                imagePicker.stopVideoCapture()
            }
        }
    }
    
    @objc func cancelClicked(){
        let alertController = UIAlertController(title: "Test not completed!",
                                                message: "Are you sure you want to leave?", preferredStyle: .alert)
        let yesAction = UIAlertAction(title: "Yes", style: .default, handler: { alert in
            self.resetTimer()
            self.isVideoRecording = false
            self.imagePicker.dismiss(animated: true, completion: nil)
        })
        let noAction = UIAlertAction(title: "No", style: .cancel, handler: nil)
        alertController.addAction(yesAction)
        alertController.addAction(noAction)
        imagePicker.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func imageTapped(_ sender: UITapGestureRecognizer) {
        let imageView = sender.view as! UIImageView
        let newImageView = UIImageView(image: imageView.image)
        newImageView.frame = UIScreen.main.bounds
        newImageView.backgroundColor = .black
        newImageView.contentMode = .scaleAspectFit
        newImageView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissFullscreenImage))
        newImageView.addGestureRecognizer(tap)
        self.view.addSubview(newImageView)
        self.navigationController?.isNavigationBarHidden = true
        self.tabBarController?.tabBar.isHidden = true
    }
    
    @objc func dismissFullscreenImage(_ sender: UITapGestureRecognizer) {
        self.navigationController?.isNavigationBarHidden = false
        self.tabBarController?.tabBar.isHidden = false
        sender.view?.removeFromSuperview()
    }
}

//MARK: Custom Methods
extension RecordViewController {
    func setUpCameraOverlay(){
        cameraOverlay = RecordView.loadNib()
        cameraOverlay.frame = UIScreen.main.bounds
        cameraOverlay.setRecordingView(isRecording: isVideoRecording)
        cameraOverlay.buttonStart.addTarget(self, action: #selector(startStopRecordingClicked),
                                            for: .touchUpInside)
        cameraOverlay.buttonCancel.addTarget(self, action: #selector(cancelClicked), for: .touchUpInside)
    }
    
    @objc func setTimer() {
        cameraOverlay.labelTimer.text = Date().timeStringSince(date: startTime)
    }
    
    @objc func resetTimer() {
        cameraOverlay.labelTimer.text = "00:00"
        startTime = Date()
        timer.invalidate()
    }
    
    func checkCameraAccess() -> Bool {
        var isPermission = false
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .denied:
            // "Denied, request permission from settings"
            self.presentCameraSettings()
        case .restricted:
            // "Restricted, device owner must approve"
            break
        case .authorized:
            // "Authorized, proceed"
            isPermission = true
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { success in
                isPermission = success
            }
        default: break
        }
        return isPermission
    }
    
    func presentCameraSettings(){
        let alertController = UIAlertController(title: "Camera access is denied",
                                                message: "We need camera access to measure your vitals",
                                                preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .default))
        alertController.addAction(UIAlertAction(title: "Settings", style: .cancel) { _ in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        })
        imagePicker.present(alertController, animated: true)
    }
    
    @objc func handleVideo(_ videoPath: String,
                           didFinishSavingWithError error: Error?,
                           contextInfo info: AnyObject ) {
        let title = (error == nil) ? "Success" : "Error"
        let message = (error == nil) ? "Video was saved" : "Video failed to save"
        
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert)
        alert.addAction(UIAlertAction(
                            title: "OK",
                            style: UIAlertAction.Style.cancel,
                            handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

// MARK: - UIImagePickerControllerDelegate
extension RecordViewController: UIImagePickerControllerDelegate {
    
    func imagePickerController( _ picker: UIImagePickerController,
                                didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if isPhotoCapture{
            imagePreview.isHidden = false
            guard let image = info[.originalImage] as? UIImage else {
                print("Image not found!")
                return
            }
            let  croppedImage = cropImage(imageToCrop: image, toRect: CGRect(
                                            x: image.size.width/4,
                                            y: 0,
                                            width: image.size.width/2,
                                            height: image.size.height)
                )

            imagePreview?.image = image
        }
        
        dismiss(animated: true, completion: nil)
    }
    func cropImage(imageToCrop:UIImage, toRect rect:CGRect) -> UIImage{
        
        let imageRef:CGImage = imageToCrop.cgImage!.cropping(to: rect)!
        let cropped:UIImage = UIImage(cgImage:imageRef)
        return cropped
    }
}

// MARK: - UINavigationControllerDelegate
extension RecordViewController: UINavigationControllerDelegate {
}


extension UIImage {
    
    func cropImage(imageToCrop:UIImage, toRect rect:CGRect) -> UIImage{
        
        let imageRef:CGImage = imageToCrop.cgImage!.cropping(to: rect)!
        let cropped:UIImage = UIImage(cgImage:imageRef)
        return cropped
    }

//    func cropped(rect: CGRect) -> UIImage? {
//        guard let cgImage = cgImage else { return nil }
//
//        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0)
//        let context = UIGraphicsGetCurrentContext()
//
//        context?.translateBy(x: 0.0, y: self.size.height)
//        context?.scaleBy(x: 1.0, y: -1.0)
//        context?.draw(cgImage, in: CGRect(x: rect.minX, y: rect.minY, width: self.size.width, height: self.size.height), byTiling: false)
//
//
//        let croppedImage = UIGraphicsGetImageFromCurrentImageContext()
//        UIGraphicsEndImageContext()
//
//        return croppedImage
//    }
}
