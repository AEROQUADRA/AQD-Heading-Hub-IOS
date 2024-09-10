import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Create a button programmatically
        let detectButton = UIButton(type: .system)
        detectButton.setTitle("Detect ArUco", for: .normal)
        detectButton.frame = CGRect(x: 100, y: 200, width: 200, height: 50) // Adjust position and size
        detectButton.addTarget(self, action: #selector(detectArucoPressed), for: .touchUpInside)

        self.view.addSubview(detectButton)
    }

    @objc func detectArucoPressed() {
        // Navigate to the ArUco detection screen
        let detectionVC = DetectionViewController()
        self.navigationController?.pushViewController(detectionVC, animated: true)
    }
}
