//
//  QRScannerController.swift
//  QRCodeReader
//
//  Created by Simon Ng on 13/10/2016.
//  Copyright © 2016 AppCoda. All rights reserved.
//

import UIKit
import AVFoundation

class QRScannerController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {

    @IBOutlet var messageLabel:UILabel!
    @IBOutlet var topbar: UIView!
    
    var captureSession: AVCaptureSession?
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var qrcodeFrameView: UIView?
    let supportedCodeTypes = [AVMetadataObject.ObjectType.upce,
                              AVMetadataObject.ObjectType.code39,
                              AVMetadataObject.ObjectType.code39Mod43,
                              AVMetadataObject.ObjectType.code93,
                              AVMetadataObject.ObjectType.code128,
                              AVMetadataObject.ObjectType.ean8,
                              AVMetadataObject.ObjectType.ean13,
                              AVMetadataObject.ObjectType.aztec,
                              AVMetadataObject.ObjectType.pdf417,
                              AVMetadataObject.ObjectType.qr]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let captureDevice = AVCaptureDevice.default(for: AVMediaType.video) {
            do {
                let input = try AVCaptureDeviceInput(device: captureDevice)
                captureSession = AVCaptureSession()
                captureSession?.addInput(input)
                
                let captureMetadataOutput = AVCaptureMetadataOutput()
                captureSession?.addOutput(captureMetadataOutput)
                
                captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
                captureMetadataOutput.metadataObjectTypes = supportedCodeTypes
                
                videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
                videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
                
                videoPreviewLayer?.frame = view.layer.bounds
                view.layer.addSublayer(videoPreviewLayer!)
                
                captureSession?.startRunning()
                
                view.bringSubviewToFront(messageLabel)
                
                view.bringSubviewToFront(messageLabel)
                
                // Initialize QR Code Frame to highlight the QR Code
                qrcodeFrameView = UIView()
                
                if let qrCodeFrameView = qrcodeFrameView{
                    qrCodeFrameView.layer.borderColor = UIColor.red.cgColor
                    qrCodeFrameView.layer.borderWidth = 3
                    view.addSubview(qrCodeFrameView)
                    //view.bringSubview(toFront: qrCodeFrameView)
                    view.bringSubviewToFront(qrCodeFrameView)
                }
                
            } catch {
                print(error)
                return
            }
        }
        else {
            print ("Error")
        }
    }
    
    func metadataOutput(_ captureOutput: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if metadataObjects == nil || metadataObjects.count == 0 {
            qrcodeFrameView?.frame = CGRect.zero
            messageLabel.text = "No QR/bar Code is Detected"
            return
        }
        
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        if supportedCodeTypes.contains(metadataObj.type) {
            let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj)
            qrcodeFrameView?.frame = barCodeObject!.bounds
            
            if metadataObj.stringValue != nil {
                let code = metadataObj.stringValue!
                messageLabel.text = code
                if (code.hasPrefix("http")) {
                    openURL(code)
                }
                
            }
        }

    }
    
    func openURL(_ url:String){
        let targetURL = URL(string: url)
        UIApplication.shared.open(targetURL!, options: [:], completionHandler: nil)
    }
}
