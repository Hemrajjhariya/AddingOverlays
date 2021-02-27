import UIKit
import MobileCoreServices
import AVKit

class PickerViewController: UIViewController {
    private let editor = VideoEditor()
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var pickButton: UIButton!
        
    @IBAction func pickVideoButtonTapped(_ sender: Any) {
        pickVideo(from: .savedPhotosAlbum)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
            
    }
        
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    private func pickVideo(from sourceType: UIImagePickerController.SourceType) {
        let pickerController = UIImagePickerController()
        pickerController.sourceType = sourceType
        pickerController.mediaTypes = [kUTTypeMovie as String]
        pickerController.videoQuality = .typeIFrame1280x720
        if sourceType == .camera {
            pickerController.cameraDevice = .front
        }
        pickerController.delegate = self
        present(pickerController, animated: true)
    }
    
    private func showVideo(at url: URL) {
        let player = AVPlayer(url: url)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        present(playerViewController, animated: true) {
            player.play()
        }
    }
    
    private var pickedURL: URL?
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard
            let url = pickedURL,
            let destination = segue.destination as? PlayerViewController
        else {
            return
        }
        
        destination.videoURL = url
    }
    
    private func showInProgress() {
        activityIndicator.startAnimating()
        pickButton.isEnabled = false
    }
    
    private func showCompleted() {
        activityIndicator.stopAnimating()
        pickButton.isEnabled = true
    }
}

extension PickerViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

        showInProgress()
        dismiss(animated: true) {
            self.pickedURL = info[.mediaURL] as? URL
            self.performSegue(withIdentifier: "showVideo", sender: nil)

        }
    }
}

extension PickerViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
