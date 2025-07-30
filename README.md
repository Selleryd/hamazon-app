# Hamazon Verifier iOS

SwiftUI app that scans barcodes or takes a product name and checks a Google Sheet via an Apps Script API.

## Requirements

- Xcode 15+  
- iOS 16+ (for DataScannerViewController)  
- Your Apps Script published as a Web App (Anyone, even anonymous)

## Setup

1. Clone this repo  
2. In **ContentView.swift** replace `apiUrl` with your `/exec` URL  
3. In **Code.gs** (Apps Script) update Spreadsheet ID & sheet name, deploy as Web App  
4. Open `HamazonVerifier.xcodeproj` in Xcode

## Running

- **Simulator**: ⌘R in Xcode  
- **Device**: sign in with a free Apple ID under Xcode ▶ Settings ▶ Apple IDs, select your device, ⌘R

No paid developer account needed until you publish to the App Store.

