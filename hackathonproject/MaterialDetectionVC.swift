//
//  MaterialDetectionVC.swift
//  hackathonproject
//
//  Created by Daniel on 1/12/20.
//  Copyright © 2020 travelU. All rights reserved.
//

import UIKit
import AVKit
import Vision

class MaterialDetectionVC: UIViewController,AVCaptureVideoDataOutputSampleBufferDelegate {
    @IBOutlet weak var detectionLabel: UILabel!
        
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let captureSession = AVCaptureSession()
        captureSession.sessionPreset = .photo
        
        
        guard let captureDevice = AVCaptureDevice.default(for: .video) else{return}
        
        guard let input = try? AVCaptureDeviceInput(device: captureDevice) else{return}
        captureSession.addInput(input)
        captureSession.startRunning()
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        view.layer.addSublayer(previewLayer)
        previewLayer.frame = view.frame
        previewLayer.addSublayer(detectionLabel.layer)
        
        let dataOutput = AVCaptureVideoDataOutput()
        dataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        captureSession.addOutput(dataOutput)
        
        
        
        
    }
    
    
    func changeText(text:String){
        self.detectionLabel.text = text
    }
    
    

    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer:CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {return}
        
        guard let model = try? VNCoreMLModel(for: MaterialClassifier_1().model) else {return}
        let request = VNCoreMLRequest(model: model){(finishedReq,err) in
            guard let results = finishedReq.results as? [VNClassificationObservation] else{return}
            
            
            guard let firstObservation = results.first else{return}
            
            print(firstObservation.identifier,firstObservation.confidence)
            DispatchQueue.main.async {
                if(firstObservation.identifier == "cardboard"){
                    self.changeText(text: "Recycle with paper")
                }else if(firstObservation.identifier == "cardboard-with-label"){
                    self.changeText(text: "remove  labels and recycle with paper")

                }else if(firstObservation.identifier == "soft_plastic"){
                    self.changeText(text: "recycle with other plastic")

                }else if(firstObservation.identifier == "electronics"){
                    self.changeText(text: "take to nearest Best Buy (1200 Rockville Pike, Rockville, MD 20852)")
                }
            }
        }
        try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform([request])
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
