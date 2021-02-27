import UIKit
import AVKit
import Photos

class PlayerViewController: UIViewController {
    
    @IBOutlet weak var txtField: UITextField!
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var pauseBtn: UIButton!
    @IBOutlet weak var btnVideoPlay: UIButton!
    
    private let editor = VideoEditor()
    private var player: AVPlayer!
    private var playerLayer: AVPlayerLayer!
    var videoURL: URL!

    
    @IBAction func saveVideoButtonTapped(_ sender: Any) {
        PHPhotoLibrary.requestAuthorization { [weak self] status in
            switch status {
            case .authorized:
                self?.saveVideoToPhotos()
            default:
                print("Photos permissions not granted.")
                return
            }
        }
    }
    
    private func saveVideoToPhotos() {
        PHPhotoLibrary.shared().performChanges( {
            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: self.videoURL)
        }) { [weak self] (isSaved, error) in
            if isSaved {
                print("Video saved.")
            } else {
                print("Cannot save video.")
                print(error ?? "unknown error")
            }
            DispatchQueue.main.async {
                self?.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: self.player?.currentItem, queue: .main) { [weak self] _ in
            self?.player?.seek(to: CMTime.zero)
            self?.btnVideoPlay.isEnabled = true
        }
        player?.rate = 1
        let playerFrame = CGRect(x: self.videoView.frame.origin.x, y: self.videoView.frame.origin.y, width: self.videoView.frame.size.width, height: self.videoView.frame.size.height)
                let playerViewController = AVPlayerViewController()
                playerViewController.player = player
                playerViewController.view.frame = playerFrame

                addChild(playerViewController)
              self.videoView.addSubview(playerViewController.view)
            let gesture = UIPanGestureRecognizer(target: self, action: #selector(userDragged(gesture:)))
        txtField.addGestureRecognizer(gesture)
        txtField.isUserInteractionEnabled = true
        
        player = AVPlayer(url: videoURL)
        playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = videoView.bounds
        videoView.layer.addSublayer(playerLayer)
        player.play()
        
        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: nil,
            queue: nil) { [weak self] _ in self?.restart() }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        playerLayer.frame = videoView.bounds
    }
    
    @objc func userDragged(gesture: UIPanGestureRecognizer){
        let loc = gesture.location(in: self.view)
        self.txtField.center = loc
        
    }
    
    private func restart() {
        player.seek(to: .zero)
        player.play()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(
            self,
            name: .AVPlayerItemDidPlayToEndTime,
            object: nil)
    }
    
    
    @IBAction func videoPlayAction (sender: UIButton) {
        
        let name = txtField.text
        
        self.editor.makeBirthdayCard(fromVideoAt: videoURL, forName: name!) { exportedURL in
           // self.showCompleted()
            guard let exportedURL = exportedURL else {
                return
            }
            
            self.btnVideoPlay.isEnabled = false
            self.pauseBtn.isEnabled = true
            self.player = AVPlayer(url: exportedURL)
            self.playerLayer = AVPlayerLayer(player: self.player)
            self.playerLayer.frame = self.videoView.bounds
            self.videoView.layer.addSublayer(self.playerLayer)
            self.player.play()
        }
    }
    
    

    @IBAction func videoPauseAction (sender: UIButton) {
        player?.pause()
        self.btnVideoPlay.isEnabled = true
        self.pauseBtn.isEnabled = false
        
    }
    
}

extension PlayerViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
