import SwiftUI
import VisionKit

@available(iOS 16.0, *)
struct ScannerView: UIViewControllerRepresentable {
    var completion: (String) -> Void

    func makeUIViewController(context: Context) -> DataScannerViewController {
        let types: [DataScannerViewController.RecognizedDataType] = [
            .barcode(.ean13),
            .barcode(.ean8),
            .barcode(.upce)
        ]
        let scanner = try! DataScannerViewController(
            recognizedDataTypes: types,
            qualityLevel: .balanced,
            recognizesMultipleItems: false,
            highlightsRecognizedData: true
        )
        scanner.delegate = context.coordinator
        return scanner
    }

    func updateUIViewController(_ uiViewController: DataScannerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    class Coordinator: NSObject, DataScannerViewControllerDelegate {
        var parent: ScannerView
        init(_ parent: ScannerView) { self.parent = parent }

        func dataScanner(
            _ dataScanner: DataScannerViewController,
            didRecognize items: [DataScannerViewController.RecognizedItem]
        ) {
            guard let code = items.compactMap({ $0 as? DataScannerViewController.RecognizedBarcode })
                                    .first?
                                    .payloadStringValue
            else { return }
            parent.completion(code)
            dataScanner.stopScanning()
        }

        func dataScanner(_ dataScanner: DataScannerViewController, didReceive error: Error) {
            print("Scanner error:", error)
        }
    }
}
