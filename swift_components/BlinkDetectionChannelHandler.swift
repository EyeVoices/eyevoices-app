import Flutter
import Foundation

/// Flutter platform channel handler for blink detection
class BlinkDetectionChannelHandler: NSObject, FlutterPlugin {
    
    // MARK: - Properties
    private var blinkDetector: BlinkDetector?
    private var channel: FlutterMethodChannel?
    
    // MARK: - Plugin Registration
    static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(
            name: "eyevoices/blink_detection",
            binaryMessenger: registrar.messenger()
        )
        
        let instance = BlinkDetectionChannelHandler()
        instance.channel = channel
        
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    // MARK: - Initialization
    override init() {
        super.init()
        setupBlinkDetector()
    }
    
    private func setupBlinkDetector() {
        blinkDetector = BlinkDetector()
        
        // Set up callback for when blinks are detected
        blinkDetector?.onBlinkDetected = { [weak self] in
            self?.notifyFlutterOfBlink()
        }
    }
    
    // MARK: - Flutter Method Channel Handler
    func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "startBlinkDetection":
            handleStartBlinkDetection(result: result)
            
        case "stopBlinkDetection":
            handleStopBlinkDetection(result: result)
            
        case "isBlinkDetectionRunning":
            handleIsBlinkDetectionRunning(result: result)
            
        case "speakSentence":
            handleSpeakSentence(call: call, result: result)
            
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    // MARK: - Method Handlers
    private func handleStartBlinkDetection(result: @escaping FlutterResult) {
        blinkDetector?.startBlinkDetection()
        result(true)
    }
    
    private func handleStopBlinkDetection(result: @escaping FlutterResult) {
        blinkDetector?.stopBlinkDetection()
        result(true)
    }
    
    private func handleIsBlinkDetectionRunning(result: @escaping FlutterResult) {
        let isRunning = blinkDetector?.isRunning ?? false
        result(isRunning)
    }
    
    private func handleSpeakSentence(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any],
              let sentence = arguments["sentence"] as? String else {
            result(FlutterError(
                code: "INVALID_ARGUMENTS",
                message: "Sentence parameter is required",
                details: nil
            ))
            return
        }
        
        // Here you would typically integrate with text-to-speech
        // For now, we'll just trigger the Flutter callback
        notifyFlutterOfSpeech(sentence: sentence)
        result(true)
    }
    
    // MARK: - Flutter Communication
    private func notifyFlutterOfBlink() {
        DispatchQueue.main.async { [weak self] in
            self?.channel?.invokeMethod("onBlinkDetected", arguments: [
                "timestamp": Date().timeIntervalSince1970
            ])
        }
    }
    
    private func notifyFlutterOfSpeech(sentence: String) {
        DispatchQueue.main.async { [weak self] in
            self?.channel?.invokeMethod("onBlinkDetected", arguments: [
                "sentence": sentence,
                "timestamp": Date().timeIntervalSince1970
            ])
        }
    }
    
    private func notifyFlutterOfError(error: String) {
        DispatchQueue.main.async { [weak self] in
            self?.channel?.invokeMethod("onBlinkDetectionError", arguments: [
                "error": error,
                "timestamp": Date().timeIntervalSince1970
            ])
        }
    }
}
