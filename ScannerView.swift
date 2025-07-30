import SwiftUI
import VisionKit

@available(iOS 16.0, *)
struct ScannerView: UIViewControllerRepresentable {
  /// Called with the barcode string when one is found
  var completion: (String) -> Void

  func makeUIViewController(context: Context) -> DataScannerViewController {
    // Only EAN-13, EAN-8 and UPC-E barcodes
    let types: [DataScannerViewController.RecognizedDataType] = [
      .barcode(symbologies: [.ean13, .ean8, .upce])
    ]

    // Because the init can throw, we wrap in a do/catch and crash if something really
    // unexpected happens. In practice this never fails at runtime on a real device.
    let controller: DataScannerViewController
    do {
      controller = try DataScannerViewController(
        recognizedDataTypes: types,
        quality: .balanced,
        recognizesMultipleItems: false
      )
    } catch {
      fatalError("Failed to create DataScannerViewController: \(error)")
    }

    controller.delegate = context.coordinator
    return controller
  }

  func updateUIViewController(_ uiViewController: DataScannerViewController, context: Context) {
    // no dynamic updates needed here
  }

  func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }

  class Coordinator: NSObject, DataScannerViewControllerDelegate {
    let parent: ScannerView

    init(_ parent: ScannerView) {
      self.parent = parent
      super.init()
    }

    func dataScanner(
      _ dataScanner: DataScannerViewController,
      didRecognize items: [DataScannerViewController.RecognizedBarcode]
    ) {
      guard let first = items.first else { return }
      parent.completion(first.payloadStringValue)
    }
  }
}

