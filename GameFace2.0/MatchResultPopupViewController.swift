//Created for GameFace  (10.03.2021 )

import UIKit
import GoogleMobileAds


class MatchResultPopupViewController: UIViewController {

    
    
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var topSubLabel: UILabel!
    @IBOutlet weak var pointsLabel: UILabel!
    
    @IBOutlet weak var adView: UIView!
    
    
    @IBOutlet weak var rematchLoader: UIActivityIndicatorView!
    @IBOutlet weak var quitBtn: UIButton!
    fileprivate var quitCompletion: (() -> Void)?
    
    var reward: RewardPoints = .win
    
    /// In this case, we instantiate the banner with desired ad size.
    private var bannerView: GADBannerView! = GADBannerView(adSize: AppConst.adSize)
    
    private var localRematchFlag = false
    private var remoteRematchFlag = false
     
    override func viewDidLoad() {
        super.viewDidLoad()

        // adMob setup
        addBannerViewToView(bannerView)
        bannerView.delegate = self
        bannerView.adUnitID = AppConst.matchResultAdUnitID
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
        // Do any additional setup after loading the view.
        setupStyle()
        
        NotificationCenter.default.addObserver(self,
        selector: #selector(MatchResultPopupViewController.handleRematch),
        name: .rematchRequest,
        object: nil)
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        print("✅ Save match result to GC: \(reward)")
        GCConnection.shared.updateScore(game: self.reward) { (error) in
            if let err = error {
                print("❌ Error: \(err)")
            }
            
            
        }
    }
    
    
    
    
    
    @objc func handleRematch(){
        remoteRematchFlag = true
        
        self.checkRematchState()
    }
    
    
    fileprivate func setupStyle() {
        
        self.definesPresentationContext = true
        
        rematchLoader.isHidden = true
        quitBtn.layer.cornerRadius = 30
        quitBtn.layer.borderWidth = 2
        quitBtn.layer.borderColor = #colorLiteral(red: 0.9457548261, green: 0.3964877725, blue: 0.162879914, alpha: 1)
        
        adView.layer.borderWidth = 1
        adView.layer.borderColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
         
         
        switch reward {
        case .win:
            topLabel.text = "Congratulations!"
            topSubLabel.text = "You Won!"
            pointsLabel.text = "3 points"
            topView.backgroundColor = #colorLiteral(red: 0.2765252888, green: 0.891702354, blue: 0.4644111991, alpha: 1)
        case .lose:
            topLabel.text = "We're Sorry :("
            topSubLabel.text = "You Lost."
            pointsLabel.text = ".5 points"
            topView.backgroundColor = #colorLiteral(red: 0.917873919, green: 0.179744333, blue: 0.1520995498, alpha: 1)
        case .draw:
            topLabel.text = "It's a Draw!"
            topSubLabel.removeFromSuperview()
            pointsLabel.text = ".5 points"
            topView.backgroundColor = #colorLiteral(red: 0.9457548261, green: 0.3964877725, blue: 0.162879914, alpha: 1)
        }
    }
    
    
    func setup(reward: RewardPoints, quitCompletion: (() -> Void)?) {
        self.reward = reward
        self.quitCompletion = quitCompletion
    }
    
    
    @IBAction func rematchTapped(sender: UIButton) {
        localRematchFlag = true
        rematchLoader.isHidden = false
        sender.isEnabled = false
        
        if let _ = try? GCConnection.shared.activeMatch?.requestRematch(withMode: .reliable) {
            print("ℹ️ Try to rematch !")
            self.checkRematchState()
        }
    }
    
    @IBAction func quitTapped(sender: UIButton) {
        dismiss(animated: true, completion: { [weak self] in
            if self?.quitCompletion != nil {self?.quitCompletion!()}
        })
    }
    
    
    private func checkRematchState() {
        if localRematchFlag && remoteRematchFlag {
            self.dismiss(animated: true, completion: nil)
            // start new match
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}



extension MatchResultPopupViewController: GADBannerViewDelegate {
    
    func addBannerViewToView(_ bannerView: GADBannerView) {
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        adView.addSubview(bannerView)
        
        adView.addConstraints([
            NSLayoutConstraint(item: bannerView,
                               attribute: .height,
                               relatedBy: .greaterThanOrEqual,
                               toItem: nil,
                               attribute: .notAnAttribute,
                               multiplier: 1,
                               constant: 10),
            
            NSLayoutConstraint(item: bannerView,
                               attribute: .width,
                               relatedBy: .greaterThanOrEqual,
                               toItem: nil,
                               attribute: .notAnAttribute,
                               multiplier: 1,
                               constant: 10),
              
            NSLayoutConstraint(item: bannerView,
                               attribute: .centerY,
                               relatedBy: .equal,
                               toItem: adView,
                               attribute: .centerY,
                               multiplier: 1,
                               constant: 0),
            
            
            NSLayoutConstraint(item: bannerView,
                               attribute: .centerX,
                               relatedBy: .equal,
                               toItem: adView,
                               attribute: .centerX,
                               multiplier: 1,
                               constant: 0)
        ])
    }
    
    /// Tells the delegate an ad request loaded an ad.
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
      print("adViewDidReceiveAd")
    }
    
    
    /// Tells the delegate an ad request failed.
    func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
        print("didFailToReceiveAdWithError: \(error)")
    }
    
    

    /// Tells the delegate that a full-screen view will be presented in response
    /// to the user clicking on an ad.
    private func adViewWillPresentScreen(_ bannerView: GADBannerView) {
      print("adViewWillPresentScreen")
    }

    /// Tells the delegate that the full-screen view will be dismissed.
    private func adViewWillDismissScreen(_ bannerView: GADBannerView) {
      print("adViewWillDismissScreen")
    }

    /// Tells the delegate that the full-screen view has been dismissed.
    private func adViewDidDismissScreen(_ bannerView: GADBannerView) {
      print("adViewDidDismissScreen")
    }

    /// Tells the delegate that a user click will open another app (such as
    /// the App Store), backgrounding the current app.
    func adViewWillLeaveApplication(_ bannerView: GADBannerView) {
      print("adViewWillLeaveApplication")
    }
}
