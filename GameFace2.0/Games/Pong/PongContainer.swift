import UIKit
import SpriteKit
import GameplayKit

import GameKit


final class PongContainer: SKView {
    fileprivate let gameScene = GameScene( fileNamed: "GameScene")!
    
    
    init(
        isHost: Bool,
        pe broadCast: @escaping (Data) -> (),
        showPopUp: @escaping (_ : RewardPoints) -> Void,
        setStatusLabelText: @escaping (Int) -> ()
    ) {
        gameScene.setUp(
            isHost: isHost,
            exportState: broadCast,
            matchFinished: showPopUp,
            ballGoesToHost: setStatusLabelText)
         
         
        gameScene.scaleMode = .aspectFit
         
        
        let slave = GCConnection.shared.activeMatch!.players
            .first{$0.alias != GKLocalPlayer.local.alias}
            .map{$0}
        
        
         
        super.init(
            frame: .zero
        )
        
        allowsTransparency = true
        //preferredFramesPerSecond = 30
        backgroundColor = .clear
         
        // Present the scene
        presentScene(gameScene)
    
        ignoresSiblingOrder = true
        
        GCConnection.shared.loadAvatar(for: GKLocalPlayer.local) {[weak self] (localImg) in
            if let s = slave {
                GCConnection.shared.loadAvatar(for: s) { [weak self] (slaveImg) in
                    self?.gameScene.updateAvatars(localImg, slaveImg)
                }
            } 
        }
        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func receiveBroadCast(_ message: Data) {
        gameScene.importState(
            message
        )
    }
    
    
    func resetScore() {
        gameScene.resetScores()
        
    }
}
