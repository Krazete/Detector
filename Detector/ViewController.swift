//
//  ViewController.swift
//  Detector
//
//  Created by Ted Michael Celis on 3/25/18.
//  Copyright © 2018 Krazete. All rights reserved.
//

import UIKit
import AVFoundation
import Clarifai_Apple_SDK

func predict(_ uiimage: UIImage, handler: @escaping (_ concept: [Concept]) -> ()) {
	let image = Image(image: uiimage)
	let dataAsset = DataAsset(image: image)
	let input = Input(dataAsset: dataAsset)
	let inputs = [input]
	
	let model = Clarifai.sharedInstance().generalModel
	model.predict(inputs, completionHandler: {(outputs, error) in
		for output in outputs! {
			handler(output.dataAsset.concepts!)
		}
	})
}

class ViewController: UIViewController, AVCapturePhotoCaptureDelegate {

	@IBOutlet var imageView: UIImageView!
	@IBOutlet var textView: UITextView!
	@IBOutlet var buttonView: UIButton!
	
	var session: AVCaptureSession?
	var sessionPreview: AVCaptureVideoPreviewLayer?
	var camera: AVCaptureDevice?
	var cameraInput: AVCaptureDeviceInput?
	var cameraOutput: AVCapturePhotoOutput?

	@IBAction func tapSafeArea(_ sender: Any) {
		let photoSettings = AVCapturePhotoSettings()
		photoSettings.isAutoStillImageStabilizationEnabled = true
		photoSettings.flashMode = .off
		cameraOutput?.capturePhoto(with: photoSettings, delegate: self)
	}

	func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
		let cgImageData = photo.cgImageRepresentation()
		let imageData = UIImage(cgImage: cgImageData!.takeUnretainedValue(), scale: 1, orientation: .right)
		predict(imageData, handler: {(concepts) in
			self.textView.text = ""
			for concept in concepts {
				self.textView.text = self.textView.text + "\n\(concept.name!), \(concept.score)"
				print(concept.name, concept.score)
			}
		})
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		
		session = AVCaptureSession()
		session!.sessionPreset = AVCaptureSession.Preset.photo
		camera = AVCaptureDevice.default(for: AVMediaType.video)
		
		var error: NSError?
		do {
			cameraInput = try AVCaptureDeviceInput(device: camera!)
		}
		catch let error1 as NSError {
			error = error1
			cameraInput = nil
			print(error!)
		}
		if error == nil && session!.canAddInput(cameraInput!) {
			session!.addInput(cameraInput!)
			cameraOutput = AVCapturePhotoOutput()
			if session!.canAddOutput(cameraOutput!) {
				session!.addOutput(cameraOutput!)
				sessionPreview = AVCaptureVideoPreviewLayer(session: session!)
				sessionPreview!.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
				sessionPreview!.videoGravity = AVLayerVideoGravity.resizeAspectFill
				sessionPreview?.frame = imageView.layer.bounds
				imageView.layer.addSublayer(sessionPreview!)
				session!.startRunning()
			}
		}
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

}

