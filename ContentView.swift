import SwiftUI

struct ContentView: View {
    @State private var isShowingScanner = false
    @State private var upc: String = ""
    @State private var productName: String = ""
    @State private var message: String = ""
    @State private var isWorking = false

    // ← Replace with your deployed Apps Script URL
    let apiUrl = "https://script.google.com/macros/s/AKfycbxNYKjBjTeCpiAzpRMWlKKLVGNhbURuVZHRjc7rpofcqUr9oapgJwuPxK5GcuxxoY02/exec"

    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                Text("Hamazon Verifier")
                    .font(.largeTitle)
                    .bold()
                Text("Enter product name or scan UPC")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                TextField("Product Name", text: $productName)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal)

                HStack {
                    TextField("UPC", text: $upc)
                        .textFieldStyle(.roundedBorder)
                    Button {
                        isShowingScanner = true
                    } label: {
                        Image(systemName: "barcode.viewfinder")
                            .font(.title2)
                    }
                    .sheet(isPresented: $isShowingScanner) {
                        if #available(iOS 16.0, *) {
                            ScannerView { code in
                                upc = code
                                isShowingScanner = false
                            }
                        } else {
                            Text("Requires iOS 16+ for scanning")
                        }
                    }
                }
                .padding(.horizontal)

                Button(action: verify) {
                    HStack {
                        if isWorking {
                            ProgressView()
                        }
                        Text("Verify")
                            .font(.headline)
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .disabled(isWorking)
                .padding(.horizontal)

                Text(message)
                    .font(.title3)
                    .foregroundColor(message.contains("Certified") ? .green : .red)
                    .padding()

                Spacer()
            }
            .navigationBarHidden(true)
        }
    }

    func verify() {
        let nameParam = productName.trimmingCharacters(in: .whitespaces)
        let upcParam  = upc.trimmingCharacters(in: .whitespaces)
        guard !nameParam.isEmpty || !upcParam.isEmpty else {
            message = "Enter a product name or UPC"
            return
        }

        isWorking = true
        message = ""

        var urlString = apiUrl + "?"
        var params: [String] = []
        if !nameParam.isEmpty {
            params.append("productName=\(nameParam.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)")
        }
        if !upcParam.isEmpty {
            params.append("upc=\(upcParam)")
        }
        urlString += params.joined(separator: "&")

        guard let url = URL(string: urlString) else {
            message = "Invalid URL"
            isWorking = false
            return
        }

        Task {
            do {
                let (data, response) = try await URLSession.shared.data(from: url)
                guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
                    throw URLError(.badServerResponse)
                }
                let apiRes = try JSONDecoder().decode(APIResponse.self, from: data)
                message = apiRes.found
                    ? "✅ Hamazon Certified!"
                    : "❌ Not Hamazon certified!"
            } catch {
                message = "Error: \(error.localizedDescription)"
            }
            isWorking = false
        }
    }
}
