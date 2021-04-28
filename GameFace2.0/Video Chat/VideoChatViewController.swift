//
//  VideoChatViewController.swift
//   GameFace2.0
//
//  Created by Eric.Fox on 3/24/18.
//  Copyright © 2018 GameFace, LLC. All rights reserved.
//
//

import UIKit
import AgoraRtcEngineKit
import GameKit

class VideoChatViewController: UIViewController {
   
    
    @IBOutlet weak var localVideo: UIView!              // Tutorial Step 3
    @IBOutlet weak var remoteVideo: UIView!             // Tutorial Step 5
    @IBOutlet weak var controlButtons: UIView!
    @IBOutlet weak var remoteVideoMutedIndicator: UIImageView!
    @IBOutlet weak var localVideoMutedBg: UIImageView!
    @IBOutlet weak var localVideoMutedIndicator: UIImageView!
    
    @IBOutlet var lblStatus: UILabel!
    @IBOutlet var titleView: UIImageView!
    
    @IBOutlet var playButton: UIButton!
    @IBOutlet weak var soresView: UIView!
    
    
    @IBOutlet weak var leftPlayerImage: UIImageView!
    @IBOutlet weak var rightPlayerImage: UIImageView!
    @IBOutlet weak var leftPlayerScore: UILabel!
    @IBOutlet weak var rightPlayerScore: UILabel!
    @IBOutlet weak var soresBarBackground: UIView!
    
    
    
    var agoraKit: AgoraRtcEngineKit!
    
    fileprivate var gameContainer: UIView?
    
    fileprivate var gameContainerSize: CGSize?
    
    fileprivate var gameContainerIsRelativelyCentered = false
    
    fileprivate var receiveBroadCast: ((Data) -> ())?
    
    fileprivate var reset: (() -> ())?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       guard let match = GCConnection.shared.activeMatch else { return }
            match.handler = self
            // Do any additional setup after loading the view.
         
        setupButtons()              // Tutorial Step 8
        hideVideoMuted()            // Tutorial Step 10
        initializeAgoraEngine()     // Tutorial Step 1
        setupVideo()                // Tutorial Step 2
        setupLocalVideo()           // Tutorial Step 3
        joinChannel()               // Tutorial Step 4
        setupScoresBar()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let viewBounds = view.bounds
        
        let unwrappedGameContainerSize = gameContainerSize!
        
        gameContainer!.frame = CGRect(
            x: round(
                viewBounds.midX
                - (
                    unwrappedGameContainerSize.width
                    / 2
                )
            ),
            y: round(
                viewBounds.midY
                + (
                    gameContainerIsRelativelyCentered
                    ? 50
                    : 0
                )
                - (
                    unwrappedGameContainerSize.height
                    / 2
                )
            ),
            width: unwrappedGameContainerSize.width,
            height: unwrappedGameContainerSize.height
        )
    }
      
    
    @IBAction func cancelMatchTouched(_ sender: Any) {
        GCConnection.shared.activeMatch?.cancel()
    }
    
    
    private func setupScoresBar() {
        let frame = playButton.convert(playButton.bounds, to: soresBarBackground)
        
        
        soresBarBackground.mask(withRect: frame, inverse: true)
        //[leftPlayerScore,rightPlayerScore].forEach({$0?.text = "1"})
    }
    
    // Tutorial Step 1
    func initializeAgoraEngine() {
        agoraKit = AgoraRtcEngineKit.sharedEngine(withAppId: AppConst.AgoraAppID, delegate: self)
    }

    // Tutorial Step 2
    func setupVideo() {
        agoraKit.enableVideo()  // Default mode is disableVideo
        agoraKit.setVideoEncoderConfiguration(
            AgoraVideoEncoderConfiguration(size: AgoraVideoDimension640x360,
            frameRate: .fps15,
            bitrate: AgoraVideoBitrateStandard,
            orientationMode: .fixedPortrait))
    }
    
    // Tutorial Step 3
    func setupLocalVideo() {
        let videoCanvas = AgoraRtcVideoCanvas()
        videoCanvas.uid = 0
        videoCanvas.view = localVideo
        videoCanvas.renderMode = .hidden
        agoraKit.setupLocalVideo(videoCanvas)
        localVideo.layer.cornerRadius = 32
    }
    
    // Tutorial Step 4
    func joinChannel() {
        agoraKit.setDefaultAudioRouteToSpeakerphone(true)
        
        agoraKit.joinChannel(
            byToken: nil,
            channelId: GCConnection.shared.activeMatch!.decisionMakerID!,
            info:nil,
            uid:0
        ) {[weak self] (sid, uid, elapsed) -> Void in
            // Join channel "demoChannel1"
            if let weakSelf = self {
                weakSelf.agoraKit.setEnableSpeakerphone(true)
                UIApplication.shared.isIdleTimerDisabled = true
            }
            print("Video Chat Connected")
        }
    }
    
    // Tutorial Step 6
//    @IBAction func didClickHangUpButton(_ sender: UIButton) {
//        leaveChannel()
//    }
    
    func leaveChannel() {
        agoraKit.leaveChannel(nil)
        hideControlButtons()   // Tutorial Step 8
        UIApplication.shared.isIdleTimerDisabled = false
        
        remoteVideo.removeFromSuperview()
        localVideo.removeFromSuperview()
    }
    
    // Tutorial Step 8
    func setupButtons() {
        perform(#selector(hideControlButtons), with:nil, afterDelay:8)
//        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(VideoChatViewController.ViewTapped))
//        view.addGestureRecognizer(tapGestureRecognizer)
        view.isUserInteractionEnabled = true
    }

    @objc func hideControlButtons() {
       // controlButtons.isHidden = true
    }
    
//    @objc func ViewTapped() {
//        if (controlButtons.isHidden) {
//            controlButtons.isHidden = true;
//            perform(#selector(hideControlButtons), with:nil, afterDelay:8)
//        }
//    }
    
    func resetHideButtonsTimer() {
        VideoChatViewController.cancelPreviousPerformRequests(withTarget: self)
        perform(#selector(hideControlButtons), with:nil, afterDelay:8)
    }
    
    // Tutorial Step 9
    @IBAction func didClickMuteButton(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        agoraKit.muteLocalAudioStream(sender.isSelected)
        resetHideButtonsTimer()
    }
    
    // Tutorial Step 10
    @IBAction func didClickVideoMuteButton(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        agoraKit.muteLocalVideoStream(sender.isSelected)
        localVideo.isHidden = sender.isSelected
        localVideoMutedBg.isHidden = !sender.isSelected
        localVideoMutedIndicator.isHidden = !sender.isSelected
        resetHideButtonsTimer()
    }
    
    func hideVideoMuted() {
       // remoteVideoMutedIndicator.isHidden = true
        //localVideoMutedBg.isHidden = true
        //localVideoMutedIndicator.isHidden = true
    }
    
    // Tutorial Step 11
    @IBAction func didClickSwitchCameraButton(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        agoraKit.switchCamera()
        resetHideButtonsTimer()
    }
    
    func setUp(_ game: Game, isHost: Bool, pear: GKPlayer?) {
        let title: UIImage
        
        let container: UIView
        
        let containerSize: CGSize
        
        let receiveBroadCast: (Data) -> ()
        
        let reset: (() -> ())?
        
        let screenBounds = UIScreen.main.bounds
        
        let fullWidthContainerSize = min(
            screenBounds.width,
            screenBounds.height
        )
        
        /// load users avatars: left image is host
        if let other = pear {
            GCConnection.shared.loadAvatar(for: other) { (image) in
                if let i = image {
                    if isHost {
                        self.rightPlayerImage.image = i
                    } else {
                        self.leftPlayerImage.image = i
                    }
                }
            }
        }
         
        GCConnection.shared.loadAvatar(for: GKLocalPlayer.local) { (image) in
            if let i = image {
                if isHost {
                    self.leftPlayerImage.image = i
                } else {
                    self.rightPlayerImage.image = i
                }
            }
        }
         
        let hostAlias = isHost ? GKLocalPlayer.local.alias : pear?.alias ?? ""
        let pearAlias = !isHost ? GKLocalPlayer.local.alias : pear?.alias ?? ""
        
        
        switch game {
        case .ticTacToe:
            title = #imageLiteral(resourceName: "Tic Tac Toe")
             
            let ticTacToeContainer = (
                Bundle.main.loadNibNamed(
                    "TicTacToeContainer",
                    owner: nil,
                    options: nil
                )!.first!
                as! TicTacToeContainer
            )
            
            ticTacToeContainer.setUp(
                broadCast: {
                    try? GCConnection.shared.activeMatch?.broadCast(
                        data: $0,
                        withMode: .reliable
                    )
                }
            ) { [unowned self] in
                
                let isHostFirst = ticTacToeContainer.isHostFirst() // is Host = X ?
                
                
                let isMeX = isHost ? isHostFirst : !isHostFirst
                   
                switch $0 {
                case .xTern:
                    self.lblStatus.text = isHostFirst ? "Turn: \(hostAlias)" : "Turn: \(pearAlias)"
                    ticTacToeContainer.lockUI(!isMeX)
                case .oTern:
                    self.lblStatus.text = !isHostFirst ? "Turn: \(hostAlias)" : "Turn: \(pearAlias)"
                    ticTacToeContainer.lockUI(isMeX)
                case .draw:
                    self.lblStatus.text = $0.rawValue
                    ticTacToeContainer.lockUI(true)
                    ticTacToeContainer.addScore(0)
                    ticTacToeContainer.addScore(1)
                case .oWin:
                    self.lblStatus.text =  !isMeX ? "You won !" : "You lose !"
                    ticTacToeContainer.lockUI(true)
                    ticTacToeContainer.addScore(!isHostFirst ? 0 : 1)
                case .xWin:
                    self.lblStatus.text =   isMeX ? "You won !" : "You lose !"
                    ticTacToeContainer.lockUI(true)
                    ticTacToeContainer.addScore(isHostFirst ? 0 : 1)
                }
                
                
                /// update scores && process it
                let scores = ticTacToeContainer.getScores()
                leftPlayerScore.text = "\(scores[0])"
                rightPlayerScore.text = "\(scores[1])"
                processScores(isHost: isHost, scores[0], scores[1])
                
                if isHost && ($0 == .xWin || $0 == .oWin || $0 == .draw) {
                   
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        ticTacToeContainer.reset()
                    }
                }
            }
            
            container = ticTacToeContainer
            
            let ticTacToeContainerSize: CGFloat = 308
            
            containerSize = CGSize(
                width: ticTacToeContainerSize,
                height: ticTacToeContainerSize
            )
            
            receiveBroadCast = ticTacToeContainer.receiveBroadCast
            reset = ticTacToeContainer.reset
        
        case .connect4:
            title = #imageLiteral(resourceName: "Connect4")
            
            let connect4Container = Connect4Container(
                isHost: isHost,
                broadCast: {
                    print("connect4: \(String(describing: String(data: $0, encoding: .utf8)))")
                    
                    try? GCConnection.shared.activeMatch?.broadCast(
                        data: $0,
                        withMode: .reliable
                    )
                }
            ) { [unowned self] in
                print("lblStatus: \($0)")
                self.lblStatus.text = "\($0)"
                
                if $0 == 0 {
                    self.lblStatus.text = "Turn: \(hostAlias)"
                } else if $0 == 1 {
                    self.lblStatus.text = "Turn: \(pearAlias)"
                } else {
                    self.lblStatus.text = ""
                }
                 
                
                
                
                
            } setScoresLabelText: { (host, slave) in
                self.leftPlayerScore.text = "\(host)"
                self.rightPlayerScore.text = "\(slave)"
                
                self.processScores(isHost: isHost ,host, slave)
                
            }
            
            container = connect4Container
            
            let connect4ContainerSize = round(
                fullWidthContainerSize * 0.9
            )
            
            containerSize = CGSize(
                width: connect4ContainerSize,
                height: connect4ContainerSize
            )
            
            receiveBroadCast = connect4Container.receiveBroadCast
            
            reset = connect4Container.reset
            
        case .pong:
            title = #imageLiteral(resourceName: "PongLabel")
            
            let pongContainer = PongContainer(
                isHost: isHost
            ) {
                try? GCConnection.shared.activeMatch?.broadCast(
                    data: $0,
                    withMode: .reliable
                )
            } showPopUp: { reward in
                
                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MatchResultPopupVC") as!  MatchResultPopupViewController
                
                vc.modalPresentationStyle = .overCurrentContext
                vc.modalTransitionStyle = .crossDissolve
                
                vc.setup(reward: reward) {
                    GCConnection.shared.activeMatch?.cancel()
                }
                
                self.present(vc, animated: true, completion: nil)
            } setStatusLabelText: {
                
                if $0 == 1 {
                    self.lblStatus.text = "Serve: \(pearAlias)"
                } else if $0 == 0 {
                    self.lblStatus.text = "Serve: \(hostAlias)"
                } 
            }
              

            
            container = pongContainer
            container.backgroundColor = .clear
            
            
            containerSize = CGSize(
                width: fullWidthContainerSize,
                height: fullWidthContainerSize * 1.5 // round( ) -> leads to a bug with bottom black line
            )
            
            gameContainerIsRelativelyCentered = true
            
            receiveBroadCast = pongContainer.receiveBroadCast
            
            reset = pongContainer.resetScore
        }
        
        gameContainer = container
        gameContainerSize = containerSize
        self.receiveBroadCast = receiveBroadCast
        self.reset = reset
        
        view.addSubview(container)
        
        titleView.image = title
         
        
        // hide reset for pong
        if ((gameContainer as? PongContainer) != nil){
            playButton.isHidden = true
            soresView.isHidden = true
        }
        
        // Force reset by host to sync random bool
        if ((gameContainer as? TicTacToeContainer) != nil) ||
            ((gameContainer as? Connect4Container) != nil) {
            if self.reset != nil && isHost {
                self.reset!()
                print("HOST: Force reset on start")
            }
        }
    }
    
    
    fileprivate func processScores(isHost: Bool, _ host: Int, _ slave: Int) {
        
        var reward: RewardPoints? = nil
        
        if isHost {
            if host >= AppConst.pointsToWin {
                reward = .win
            } else if slave >= AppConst.pointsToWin {
                reward = .lose
            }
        } else {
            if host >= AppConst.pointsToWin {
                reward = .lose
            } else if slave >= AppConst.pointsToWin {
                reward = .win
            }
        }
        
        if host >= AppConst.pointsToWin && slave >= AppConst.pointsToWin {
            reward = .draw
        }
        
        if let r = reward,
           let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MatchResultPopupVC") as?  MatchResultPopupViewController {
            
            vc.modalPresentationStyle = .overCurrentContext
            vc.modalTransitionStyle = .crossDissolve
            
            vc.setup(reward: r) {
                GCConnection.shared.activeMatch?.cancel()
            }
            
            self.present(vc, animated: true, completion: {
                self.reset!()
            })
        }
    }
      
    @IBAction func btnPlayTapped(sender: UIButton) {
        let startImage = UIImage(named: "StartButton")
        let pauseImage = UIImage(named: "Pause_Button")
        
        // current see
        let isPause = sender.image(for: .normal) != startImage
         
        gameContainer?.isHidden = isPause
         
        sender.setImage(!isPause ? pauseImage: startImage, for: .normal)
    }
    
    
}

extension VideoChatViewController: AgoraRtcEngineDelegate {

    // TestChat Integration
   
    // Tutorial Step 5
    func rtcEngine(_ engine: AgoraRtcEngineKit, firstRemoteVideoDecodedOfUid uid:UInt, size:CGSize, elapsed:Int) {
        if (remoteVideo.isHidden) {
            remoteVideo.isHidden = true
        }
        let videoCanvas = AgoraRtcVideoCanvas()
        videoCanvas.uid = uid
        videoCanvas.view = remoteVideo
        videoCanvas.renderMode = .hidden
        agoraKit.setupRemoteVideo(videoCanvas)
       
    }
    
    // Tutorial Step 7
    internal func rtcEngine(_ engine: AgoraRtcEngineKit, didOfflineOfUid uid:UInt, reason:AgoraUserOfflineReason) {
        self.remoteVideo.isHidden = false
    }
    
    // Tutorial Step 10
    func rtcEngine(_ engine: AgoraRtcEngineKit, didVideoMuted muted:Bool, byUid:UInt) {
        remoteVideo.isHidden = muted
        remoteVideoMutedIndicator.isHidden = !muted
    }
    
        
        override var preferredStatusBarStyle: UIStatusBarStyle {
            return .lightContent
        }
        
        
}
    
//  GameCenter2 Data Handle Test Start
extension VideoChatViewController : MatchHandler {
    func handle(rematch: Bool, fromPlayer: GKPlayer) {
        if reset != nil {reset!()}
        NotificationCenter.default.post(name: .rematchRequest, object: nil, userInfo: nil)
    }
    
            func handle(_ error : Error){
                // show errors or not ...
            }
            func handle(_ state : MatchState){
                switch state {
                case .connected:
                    // nothing to do here on the player screen
                    print("connected ...")
                case .disconnected(reason: .cancel):
                    // player disconnected, you should go here back
                    self.dismissMyself()
                case .disconnected(reason: .matchMakingTimeout):
                    // should be checked already in the parent screen
                    print("matchMakingTimeout ...")
                case .disconnected(reason: .matchEmpty):
                    // player leaved the match.. should go back
                    self.dismissMyself()
                case .disconnected(reason: .error):
                    // error
                    self.dismissMyself()
                case .pending:
                    // nothing to do here
                    print("pending ...")
                }
            }
    
    
            func handle(data : Data, fromPlayer : GKPlayer){
                receiveBroadCast!(data)
            }
            func handle(playerDisconnected : GKPlayer){
                // player disconnected
                //GCConnection.shared.activeMatch?.cancel()
                print("‼️ player \(playerDisconnected.alias) disconnected ! ")
            }
            
            func dismissMyself(){
                print("dissmiss myself")
                //GCConnection.shared.activeMatch?.cancel()
                self.leaveChannel()
                if let vc = presentedViewController as? MatchResultPopupViewController {
                    vc.dismiss(animated: true, completion: nil)
                }
                
                self.dismiss(animated: true, completion: {
                    
                    self.receiveBroadCast = nil
                    self.reset = nil
                    
                    
                    self.view.subviews.forEach {
                        //print($0)
                        if $0 == self.gameContainer {
                            
                            $0.removeFromSuperview()
                            //print("REMOVE GC FROM VIEW")
                        }
                    }
//                    print("+++++++++++++++")
//                    self.view.subviews.forEach { print($0)}
                    self.gameContainer = nil
                     
                })
                NotificationCenter.default.post(name: .gameDismissed, object: nil)
            }
        }
    

    //  GameCenter2 Data Handle Test End



