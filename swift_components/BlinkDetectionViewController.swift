import UIKit

/// Main view controller for the Swift blink detection component
class BlinkDetectionViewController: UIViewController {
    
    // MARK: - Properties
    private var blinkDetector: BlinkDetector?
    
    // UI Elements
    private lazy var statusLabel: UILabel = {
        let label = UILabel()
        label.text = "Blink Detection Ready"
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        label.textColor = .systemGreen
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var startButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Start Detection", for: .normal)
        button.setTitle("Stop Detection", for: .selected)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 25
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(toggleDetection), for: .touchUpInside)
        return button
    }()
    
    private lazy var instructionLabel: UILabel = {
        let label = UILabel()
        label.text = "This component detects eye blinks and triggers speech in the main Flutter app.\n\nTap 'Start Detection' to begin monitoring for blinks."
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBlinkDetector()
    }
    
    // MARK: - Setup Methods
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Blink Detection"
        
        view.addSubview(statusLabel)
        view.addSubview(startButton)
        view.addSubview(instructionLabel)
        
        NSLayoutConstraint.activate([
            // Status Label
            statusLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            statusLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 60),
            
            // Start Button
            startButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            startButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            startButton.widthAnchor.constraint(equalToConstant: 200),
            startButton.heightAnchor.constraint(equalToConstant: 50),
            
            // Instruction Label
            instructionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            instructionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            instructionLabel.topAnchor.constraint(equalTo: startButton.bottomAnchor, constant: 40)
        ])
    }
    
    private func setupBlinkDetector() {
        blinkDetector = BlinkDetector()
    }
    
    // MARK: - Actions
    @objc private func toggleDetection() {
        startButton.isSelected.toggle()
        
        if startButton.isSelected {
            blinkDetector?.startBlinkDetection()
            statusLabel.text = "Detecting Blinks..."
            statusLabel.textColor = .systemOrange
            startButton.backgroundColor = .systemRed
        } else {
            blinkDetector?.stopBlinkDetection()
            statusLabel.text = "Blink Detection Ready"
            statusLabel.textColor = .systemGreen
            startButton.backgroundColor = .systemBlue
        }
    }
}

// MARK: - Preview Support
#if DEBUG && canImport(SwiftUI)
import SwiftUI

@available(iOS 13.0, *)
struct BlinkDetectionViewController_Preview: PreviewProvider {
    static var previews: some View {
        UIViewControllerPreview {
            BlinkDetectionViewController()
        }
    }
}

struct UIViewControllerPreview<ViewController: UIViewController>: UIViewControllerRepresentable {
    let viewController: ViewController

    init(_ builder: @escaping () -> ViewController) {
        viewController = builder()
    }

    func makeUIViewController(context: Context) -> ViewController {
        viewController
    }

    func updateUIViewController(_ uiViewController: ViewController, context: Context) {}
}
#endif
