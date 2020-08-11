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

    // Class Properties
    let imagePicker = UIImagePickerController()
    var cameraOverlay =  RecordView()
    var isVideoRecording = false
    var timer = Timer()
    var startTime = Date()

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

//MARK: Button Actions
extension RecordViewController {
    @IBAction func buttonStartStopRecording(_ sender: Any) {
        setUpCameraOverlay()
        if !checkCameraAccess(){
            return
        }
        if(UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera)) {
            imagePicker.delegate = self
            imagePicker.sourceType = .camera
            imagePicker.mediaTypes = [kUTTypeMovie as String]
            //        mediaUI.allowsEditing = true
            imagePicker.cameraOverlayView = cameraOverlay
            imagePicker.showsCameraControls = false
            imagePicker.cameraFlashMode = .off
            self.present(imagePicker, animated: true, completion: nil)
        }
    }

    @objc func startStopRecordingClicked(){
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
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - UINavigationControllerDelegate
extension RecordViewController: UINavigationControllerDelegate {
}
