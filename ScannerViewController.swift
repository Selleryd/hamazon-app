// ScannerViewController.swift

import UIKit
import AVFoundation

/// A delegate protocol so SwiftUI’s ScannerView can hand back the found code.
protocol ScannerDelegate: AnyObject {
    func didFind(code: String)
}

class ScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    weak var delegate: ScannerDelegate?
    private var captureSession: AVCaptureSession!

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .black
        captureSession = AVCaptureSession()

        // 1) Input: the camera
        guard let videoInput = try? AVCaptureDeviceInput(device: AVCaptureDevice.default(for: .video)!)
        else {
            print("Unable to obtain video input")
            return
        }
        captureSession.addInput(videoInput)

        // 2) Output: metadata (barcodes)
        let metadataOutput = AVCaptureMetadataOutput()
        guard captureSession.canAddOutput(metadataOutput) else { return }
        captureSession.addOutput(metadataOutput)

        // Set delegate to receive metadata objects
        metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        // We're interested in EAN‑8, EAN‑13, UPC‑E barcodes:
        metadataOutput.metadataObjectTypes = [.ean8, .ean13, .upce]

        // 3) Preview layer so the user sees camera feed
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)

        // Start running the session
        captureSession.startRunning()
    }

    // MARK: - AVCaptureMetadataOutputObjectsDelegate

    func metadataOutput(_ output: AVCaptureMetadataOutput,
                        didOutput metadataObjects: [AVMetadataObject],
                        from connection: AVCaptureConnection) {
        // We only need the first detected barcode
        guard let readableObject = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
              let stringValue   = readableObject.stringValue
        else { return }

        // Stop the session so we don't keep scanning
        captureSession.stopRunning()

        // Haptic feedback
        AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))

        // Inform the SwiftUI wrapper
        delegate?.didFind(code: stringValue)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if captureSession.isRunning {
            captureSession.stopRunning()
        }
    }

    deinit {
        if captureSession.isRunning {
            captureSession.stopRunning()
        }
    }
}
