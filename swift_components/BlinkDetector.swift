import Foundation
import AVFoundation
import UIKit

/// BlinkDetector class for detecting eye blinks using the device camera
class BlinkDetector: NSObject {
    
    // MARK: - Properties
    private var captureSession: AVCaptureSession?
    private var videoDataOutput: AVCaptureVideoDataOutput?
    private var videoDataOutputQueue: DispatchQueue?
    private var isDetectionRunning = false
    
    // API endpoint configuration
    private let apiEndpoint = "http://localhost:8080/blink"
    
    // Callback for blink detection
    var onBlinkDetected: (() -> Void)?
    
    // MARK: - Public Properties
    var isRunning: Bool {
        return isDetectionRunning
    }
    
    // MARK: - Initialization
    override init() {
        super.init()
        setupCaptureSession()
    }
    
    // MARK: - Setup Methods
    private func setupCaptureSession() {
        captureSession = AVCaptureSession()
        
        // Configure camera input
        guard let frontCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) else {
            print("❌ Unable to access front camera")
            return
        }
        
        do {
            let input = try AVCaptureDeviceInput(device: frontCamera)
            captureSession?.addInput(input)
        } catch {
            print("❌ Error setting up camera input: \(error)")
            return
        }
        
        // Configure video output
        videoDataOutput = AVCaptureVideoDataOutput()
        videoDataOutput?.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoDataOutputQueue"))
        
        if let videoDataOutput = videoDataOutput {
            captureSession?.addOutput(videoDataOutput)
        }
        
        print("✅ Capture session configured successfully")
    }
    
    // MARK: - Public Methods
    func startBlinkDetection() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.captureSession?.startRunning()
            self?.isDetectionRunning = true
            print("🎥 Blink detection started")
        }
    }
    
    func stopBlinkDetection() {
        captureSession?.stopRunning()
        isDetectionRunning = false
        print("⏹️ Blink detection stopped")
    }
    
    // MARK: - Blink Detection Logic
    private func detectBlink(in sampleBuffer: CMSampleBuffer) {
        // TODO: Implement actual computer vision blink detection
        // For now, we'll simulate blink detection with a timer
        // In a real implementation, you would use:
        // - Vision framework for face detection
        // - Core ML for eye state classification
        // - MLKit for face landmarks
        
        // Simulated blink detection (replace with real implementation)
        let shouldSimulateBlink = Int.random(in: 0...100) < 2 // 2% chance per frame
        
        if shouldSimulateBlink {
            print("👁️ Blink detected!")
            
            // Notify via callback (for platform channel)
            onBlinkDetected?()
            
            // Also notify via HTTP API (for backup communication)
            notifyFlutterApp()
        }
    }
    
    // MARK: - API Communication
    private func notifyFlutterApp() {
        guard let url = URL(string: apiEndpoint) else {
            print("❌ Invalid API endpoint URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = ["timestamp": Date().timeIntervalSince1970]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch {
            print("❌ Error serializing JSON: \(error)")
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ API call error: \(error)")
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("✅ API call successful, status: \(httpResponse.statusCode)")
            }
        }.resume()
    }
}

// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate
extension BlinkDetector: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        detectBlink(in: sampleBuffer)
    }
}
