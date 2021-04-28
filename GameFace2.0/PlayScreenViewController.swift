//
//  PlayScreenViewController.swift
//  
//
//  Created by Eric.Fox on 10/5/18.
//

import UIKit
import GameKit



class PlayScreenViewController: UIViewController {

    private let shareURLString = "https://apps.apple.com/us/app/gameface-video-chat/id1462710737"
   

    @IBOutlet weak var header: UIView!
    @IBOutlet weak var playButton: UIButton!
    
    @IBOutlet weak var statusLbl: UILabel!
    
    @IBOutlet weak var menuButton: UIButton!
    
    fileprivate var selected: Game?
    
    fileprivate var menuScreenWithIsVisible: (UIView, Bool)?
    
    fileprivate var localScores: [LeaderboardInfo] = []
    
    
     
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    
    @IBAction func startTouched(_ sender: Any) {
        if GCConnection.shared.authenticated {
            
            //TODO:
            GCConnection.shared.loadScores { (scores, err) in
                print("Just try to update local storage")
                if scores.count > 0 {
                    self.localScores = scores
                }
            }
            
            // we are connected ...
            if GCConnection.shared.activeMatch == nil {
                print("start matchmaking ...")
                // ... but don't have a match ...
                let match = try! GCConnection.shared.findMatch(
                    selected,
                    minPlayers: 2,
                    maxPlayers: 2
                )
                
                match.handler = self
            } else{
                print("have already a match ...")
                // and have a match ...
            }
            
            
        }else{
            // not authenticated...
            // the start button is a connect button
            // show login dialog or handle all other auth states
            GCConnection.shared.authHandler = self
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self,
        selector: #selector(PlayScreenViewController.handleGameDismissed),
        name: .gameDismissed,
        object: nil)
        
        menuButton.addTarget(
            self,
            action: #selector(PlayScreenViewController.menuButtonPressed),
            for: .touchUpInside
        )
    }
    
    @objc func handleGameDismissed(){
        self.updateGCUIStates()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
       
        let rippleLayer = RippleLayer()
        rippleLayer.position = CGPoint(x: self.view.layer.bounds.midX, y: self.view.layer.bounds.midY);
        
      
        self.view.layer.insertSublayer(rippleLayer, below: playButton.layer)
        self.view.layer.insertSublayer(rippleLayer, below: header.layer)
        rippleLayer.startAnimation()
        
        self.updateGCUIStates()
    }
 
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if let (menuScreen, menuScreenIsVisible) = menuScreenWithIsVisible {
            let viewBounds = view.bounds
            
            menuScreen.frame = viewBounds.inset(
                by: UIEdgeInsets(
                    top: header.frame.height,
                    left: 0,
                    bottom: 0,
                    right: 0
                )
            ).offsetBy(
                dx: (
                    menuScreenIsVisible
                    ? 0
                    : viewBounds.width
                ),
                dy: 0
            )
        }
    }
    
    func updateGCUIStates(){
        
        let authenticated = GCConnection.shared.authenticated
         
        self.statusLbl.text = authenticated ? "" : "Press Connect to Log in to Game Center"
        self.playButton.setImage(
            authenticated ? UIImage(named: "PlayButton_2")! : UIImage(named: "Connect_Button2")!,
            for: .normal)
    }
   
    
    @objc fileprivate func menuButtonPressed() {
        if let (menuScreen, _) = menuScreenWithIsVisible {
            menuButton.setImage(#imageLiteral(resourceName: "Hamburger_Round_1"), for: .normal)
            
            UIView.animate(
                withDuration: 0.3,
                animations: {
                    self.menuScreenWithIsVisible = (menuScreen, false)
                    
                    self.layoutView()
                }
            ) { _ in
                self.menuScreenWithIsVisible = nil
                
                menuScreen.removeFromSuperview()
            }
        } else {
            menuButton.setImage(#imageLiteral(resourceName: "Hamburger_Round_2"), for: .normal)
            
            let menuScreen = GameFace1010.menuScreen(
                initiallySelected: selected
            ) { [unowned self] in
                self.selected = $0
                 
            }
            
            menuScreenWithIsVisible = (menuScreen, false)
            
            view.addSubview(menuScreen)
            
            layoutView()
            
            UIView.animate(
                withDuration: 0.3
            ) {
                self.menuScreenWithIsVisible = (menuScreen, true)
                
                self.layoutView()
            }
        }
    }
    
    @objc func pushLeaderboard() {
        guard let leaderboardVC = self.storyboard?.instantiateViewController(withIdentifier: "LeaderboardVC") else {return}
        
        self.present(leaderboardVC, animated: true) {
            
        }
    }
}

extension PlayScreenViewController : MatchHandler{
    func handle(rematch: Bool, fromPlayer: GKPlayer) {
        print("ℹ️ Rematch handle")
    }
    
    
    func handle(_ error : Error){
        self.playButton.setImage(UIImage(named: "PlayButton_2")!, for: .normal)
        self.statusLbl.text = "GameCenter Communication Error. Please Try Again."
    }
    
    func handle(_ state : MatchState){
        switch state {
        case .connected(let game, let isHost):
            let local = GKLocalPlayer.local.alias
            
            let match = GCConnection.shared.activeMatch!
            
            let other = match.players
                                    .first{$0.alias != local}
                                    .map{$0}
            
             
            print("connected!| local: \(local) | peer: \(String(describing: other))")
         
            
            // we have a peer, go now to the game screen
            let videoChatViewController = (
                UIStoryboard(name: "Main", bundle: nil )
                    .instantiateViewController(withIdentifier: "VideoChatViewController" )
                as! VideoChatViewController
            )
            
            videoChatViewController.setUp(
                game,
                isHost: isHost,
                pear: other
            )
            
            present(
                videoChatViewController,
                animated: true
            )
        case .disconnected(reason: .cancel):
            print("disconnected! | reason: cancel")
            self.statusLbl.text = "Matchmaking was Cancelled, Try Again."
        case .disconnected(reason: .matchMakingTimeout):
            print("disconnected! | reason: timeout")
            self.statusLbl.text = "Matchmaking Timed-out, Try Again."
        case .disconnected(reason: .matchEmpty):
            print("disconnected! | reason: matchEmpty")
            self.statusLbl.text = "Player has Left, Try Again."
        case .disconnected(reason: .error):
            print("disconnected! | reason: error")
        case .pending:
            print("pending!")
            self.statusLbl.text = "Looking for Players, Please Wait..."
        }
    }
    func handle(data : Data, fromPlayer : GKPlayer){
        // we got a message from the peer, but this should be handled on the game screen
        // you can also handle it first here to exchange the "telephone numbers"
        // and go than to the game screen
        
    }
    func handle(playerDisconnected : GKPlayer){
        
    }
}

extension PlayScreenViewController : AuthHandler{
    func handle(connection: GCConnection, authStatusChanged: AuthStatus) {
        switch GCConnection.shared.authStatus {
            case .undef:
                //  this should never happen when we called GCConnection.authenticate
                print("auth stat undef")
                break
            // not authenticated
            case .loginCancelled:
                // show user an message that he cancelled the authentication
                // and needs a login
                self.statusLbl.text = "GameCenter Login Cancelled. Please Login in Settings."
//                self.playButton.isEnabled = false;
                
                print("auth stat loginCancelled")
                break
            // login canccelled 🙅‍♀️
            case .error( _):
                // error ..
                self.statusLbl.text = "Not authenticated. Please log in to GameCenter in Settings."
                
                print("auth stat error")
                break
            // auth err
            case .loginRequired(let vc):
                // when a login is required, show the viewcontroller (GameCenter Login VC)
                self.present(vc, animated: true, completion: nil)
                print("auth stat loginRequired")
                break
                // login required
            // show present ViewController - it is the GC login view
            case .ok( _):
                // game center authentication was successfull, we can start the game
                self.playButton.setImage(UIImage(named: "PlayButton_2"), for: .normal)
                self.updateGCUIStates()
                
                print("auth stat ok")
                break
        }
    }
    
    @IBAction func urlShareButtonPressed(_ sender: UIButton) {
        guard let url = URL(string: shareURLString) else {
            return
        }
        
        let vc = VisualActivityViewController(url: url)
        vc.previewLinkColor = .magenta

        presentActionSheet(vc, from: sender)
    }

    private func presentActionSheet(_ vc: VisualActivityViewController, from view: UIView) {
        if UIDevice.current.userInterfaceIdiom == .pad {
            vc.popoverPresentationController?.sourceView = view
            vc.popoverPresentationController?.sourceRect = view.bounds
            vc.popoverPresentationController?.permittedArrowDirections = [.right, .left]
        }
        
        present(vc, animated: true, completion: nil)
    }
}

extension UIViewController {
    fileprivate func layoutView() {
        view.setNeedsLayout()
        
        view.layoutIfNeeded()
    }
}
