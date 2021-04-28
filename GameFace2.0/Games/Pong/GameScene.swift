//
//  GameScene.swift
//  Pong2
//
//  Created by Jared Davidson on 10/11/16.
//  Copyright © 2016 Archetapp. All rights reserved.
//

import SpriteKit
import GameplayKit



final class GameScene: SKScene {
    fileprivate var ball = SKSpriteNode()
    fileprivate var enemy = SKSpriteNode()
    fileprivate var main = SKSpriteNode()
    
    fileprivate var topLbl = SKLabelNode()
    fileprivate var btmLbl = SKLabelNode()
    
    fileprivate var score = [0, 0]
    
    fileprivate var startButton:SKSpriteNode!
    fileprivate let worldNode = SKNode()
    
    fileprivate var gameIndex = 0
    
    fileprivate var isHost = false
    fileprivate var exportState: ((Data) -> ())?
    
    fileprivate var finished: ((_ reward: RewardPoints) -> ())?
    fileprivate var ballGoesToHost: ((Int) -> Void)?
    
    fileprivate var ballDirrection: BallDirection = .stopped
    
    override func didMove(to view: SKView) {
        
   startButton = (self.childNode(withName: "startButton") as! SKSpriteNode)
        startButton.texture = SKTexture(imageNamed: "StartButton")
 
        topLbl.fontColor = UIColor.white
        btmLbl.fontColor = UIColor.white
        
        topLbl = self.childNode(withName: "topLabel") as! SKLabelNode
        btmLbl = self.childNode(withName: "btmLabel") as! SKLabelNode
        ball = self.childNode(withName: "ball") as! SKSpriteNode
        
        print(self.view?.bounds.height as Any)
        
        enemy = self.childNode(withName: "enemy") as! SKSpriteNode
        enemy.position.y = (self.frame.height / 2) - 50
        
        main = self.childNode(withName: "main") as! SKSpriteNode
        main.position.y = (-self.frame.height / 2) + 50
        
        let border  = SKPhysicsBody(edgeLoopFrom: self.frame)
        
        border.friction = 0
        border.restitution = 1
         
        self.physicsBody = border
         
    }
    
    fileprivate func startGame() {
        score = [0,0]
         
        ball.position = .zero
        
        ball.physicsBody!.velocity = .zero
        
        ball.physicsBody!.applyImpulse(CGVector(dx: 10 , dy: 10))
        physicsWorld.speed = 1
        gameIndex = 1
        
        updateScore()
        updateStartButton()
    }
    
    fileprivate func pauseGame(index: Int) {
        physicsWorld.speed = 0
        
        gameIndex = index
        gameIsHidden(true)
        updateStartButton()
    }
    
    fileprivate func resumeGame(index: Int) {
        physicsWorld.speed = 1
        
        gameIndex = index
        gameIsHidden(false)
        updateStartButton()
    }
    
    func resetGame() {
         
        gameIndex = 0
        
        ball.position = .zero
        ball.physicsBody!.velocity = .zero
        physicsWorld.speed = 0
        ball.physicsBody!.applyImpulse(CGVector(dx: 10 , dy: 10))
        updateStartButton()
    }
    
    func resetScores() {
        score = [0,0]
        gameIsHidden(false)
        updateScore()
    }
    
    
    
    fileprivate func gameIsHidden(_ isHidden: Bool) {
        
        [   enemy,
            main,
            ball,
            childNode(withName: "halfCourtLine") as! SKSpriteNode,
            childNode(withName: "halfCourtLine2") as! SKSpriteNode
        ]
        .forEach { $0.isHidden = isHidden }
         
    }

    fileprivate func addScore(playerWhoWon : SKSpriteNode){
         
        // reset the ball
        ball.position = CGPoint(x: 0, y: 0)
        ball.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
        
        if playerWhoWon == main {
            score[0] += 1
            ball.physicsBody?.applyImpulse(CGVector(dx: 10, dy: 10))
        } else if playerWhoWon == enemy {
            score[1] += 1
            ball.physicsBody?.applyImpulse(CGVector(dx: -10, dy: -10))
        }
        
        print("ADD SCORE: \(score)")
         
        updateScore()
    }
    
    fileprivate func processScore(){
        let scoreToWin = AppConst.pointsToWin
         
        
        if score[0] >= scoreToWin || score[1] >= scoreToWin {
            
            var reward: RewardPoints = .win
             
            print("ℹ️ processScore")
             
            if isHost {
                pauseGame(index: gameIndex + 1)
                
                print("‼️ My score in game is: \(score[0])")
                 
                if score[0] >= scoreToWin { // host win (me)
                    reward = .win
                } else {
                    reward = .lose
                }
            } else {
                print("‼️ My score in game is: \(score[1])")
                
                if score[1] >= scoreToWin {
                    reward = .win
                } else {
                    reward = .lose
                }
            }
             
            finished!(reward)
        }
    }
    
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            
            let nodesArray = self.nodes(at: location)//if the touch coordinate equal a button contenue
            
            if nodesArray.first?.name == "startButton"{
                switch gameIndex {
                case 0:
                    startGame()
                    
                case let index where index % 2 == 1:
                    pauseGame(
                        index: gameIndex + 1
                    )
                    
                default:
                    resumeGame(
                        index: gameIndex + 1
                    )
                }
            }
        }
    }
   
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
       for touch in touches {
            let location = touch.location(in: self)
            
            main.run(SKAction.moveTo(x: location.x, duration: 0.2))
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
         
        if let bv = self.ball.physicsBody?.velocity {
            ballDirrection = bv.dy > 0.1 ? .up : .down
            
            if bv == .zero {ballDirrection = .stopped}
        }
        
        
        switch ballDirrection {
        case .up:
            self.ballGoesToHost!(!isHost ? 1 : 0)
        case .down:
            self.ballGoesToHost!(isHost ? 1 : 0)
        default:
            break
        }
         
        if let viewWidth = view?.bounds.width, viewWidth != 0 {
            startButton.setScale(
                400 / viewWidth
            )
        }
        
        if ball.position.y <= main.position.y - 30 {
            addScore(playerWhoWon: enemy)
            
        } else if ball.position.y >= enemy.position.y + 30 {
            addScore(playerWhoWon: main)
        }
        
        
        if let exportState = exportState {
            let encoder = JSONEncoder()
            
            let main = PongClientState(
                gameIndex: self.gameIndex,
                barXPosition: self.main.position.x
            )
            
            exportState(
                isHost
                ? try! encoder.encode(
                    PongHostState(
                        main: main,
                        ballPosition: ball.position,
                        ballVelocity: ball.physicsBody!.velocity,
                        score: score
                    )
                )
                : try! encoder.encode(
                    main
                )
            )
        }
    }
    
    fileprivate func updateScore() {
        topLbl.text = "\(score[1])" // eneny
        btmLbl.text = "\(score[0])" // main
        
        processScore()
    }
    
    func updateAvatars(_ local: UIImage?, _ slave: UIImage?) {
        let top = self.childNode(withName: "topAvatar") as! SKSpriteNode
        let bottom = self.childNode(withName: "bottomAvatar") as! SKSpriteNode
        
         
        if let l = local,
           let img = l.circleMasked {
            
            bottom.texture?.filteringMode = .nearest
            
            if isHost {
                bottom.texture = SKTexture(image: img)
            } else {
                top.texture = SKTexture(image: img)
            }
        }
        
        if let s = slave,
           let img = s.circleMasked {
            
            let texture = SKTexture(image: img)
            texture.filteringMode = .linear
             
            if !isHost {
                bottom.texture = texture
            } else {
                top.texture = texture
            }
        } 
    }
    
    
    fileprivate func updateStartButton() {
        startButton.texture = SKTexture(
            image: ( gameIndex % 2 == 0 ? #imageLiteral(resourceName: "StartButton") : #imageLiteral(resourceName: "Pause_Button") )
        )
    }
    
    fileprivate func importEnemy(_ enemyState: PongClientState) {
        let enemyGameIndex = enemyState.gameIndex
        
        if enemyGameIndex > gameIndex {
            switch enemyGameIndex {
            case 1:
                startGame()
                
            case let index where index % 2 == 0:
                pauseGame( index: index )
                
            default:
                resumeGame( index: enemyGameIndex )
            }
        } else if enemyGameIndex == 0  { //&& gameIndex != 0?
            //self.gameIndex = 0
            //resetGame()
        }
        
        
        enemy.position.x = enemyState.barXPosition
    }
    
    func setUp(
        isHost: Bool,
        exportState: ((Data) -> ())?,
        matchFinished: ((_ reward: RewardPoints) -> ())?,
        ballGoesToHost: ((Int) -> Void)?
    
    
    ) {
        self.isHost = isHost
        self.exportState = exportState
        self.finished = matchFinished
        self.ballGoesToHost = ballGoesToHost
        self.updateAvatars(nil, nil)
         
    }
    
    func importState(_ state: Data) {
        let decoder = JSONDecoder()
        //    DEBUG:  print(String(data: state, encoding: .utf8) )
        
        if isHost {
            if let enemyState = try? decoder.decode(PongClientState.self, from: state ) {
                importEnemy(enemyState)
            }
        } else if
            let hostState = try? decoder.decode(PongHostState.self, from: state ),
            hostState.score.count == 2 {
            importEnemy(hostState.main)
            
            let flippedBallPosition = hostState.ballPosition
            
            ball.position = CGPoint(
                x: flippedBallPosition.x,
                y: -flippedBallPosition.y
            )
            
            ball.physicsBody!.velocity = hostState.ballVelocity
            
            if score != hostState.score {
                score = hostState.score
                updateScore()
            }
        }
    }
     
}

fileprivate struct PongClientState: Codable {
    fileprivate var gameIndex: Int
    fileprivate var barXPosition: CGFloat
}

fileprivate struct PongHostState: Codable {
    fileprivate var main: PongClientState
    
    fileprivate var ballPosition: CGPoint
    
    fileprivate var ballVelocity: CGVector
    
    fileprivate var score: [Int]
}




extension SKSpriteNode {
    func addTo(parent:SKNode?, withRadius:CGFloat) {
        guard parent != nil else { return }
        guard  withRadius>0.0 else {
            parent!.addChild(self)
            return
        }
        let radiusShape = SKShapeNode.init(rect: CGRect.init(origin: CGPoint.zero, size: size), cornerRadius: withRadius)
        radiusShape.position = CGPoint.zero
        radiusShape.lineWidth = 2.0
        radiusShape.fillColor = UIColor.red
        radiusShape.strokeColor = UIColor.red
        radiusShape.zPosition = 2
        radiusShape.position = CGPoint.zero
        let cropNode = SKCropNode()
        cropNode.position = self.position
        cropNode.zPosition = 3
        cropNode.addChild(self)
        cropNode.maskNode = radiusShape
        parent!.addChild(cropNode)
    }
}




extension UIImage {
    
    var isPortrait:  Bool    { return size.height > size.width }
    var isLandscape: Bool    { return size.width > size.height }
    var breadth:     CGFloat { return min(size.width, size.height) }
    var breadthSize: CGSize  { return CGSize(width: breadth, height: breadth) }
    var breadthRect: CGRect  { return CGRect(origin: .zero, size: breadthSize) }
    
    var circleMasked: UIImage? {
        
        UIGraphicsBeginImageContextWithOptions(breadthSize, false, scale)
        defer { UIGraphicsEndImageContext() }
        
        guard let cgImage = cgImage?.cropping(to: CGRect(origin:
            CGPoint(
                x: isLandscape ? floor((size.width - size.height) / 2) : 0,
                y: isPortrait  ? floor((size.height - size.width) / 2) : 0),
            size: breadthSize))
        else { return nil }
        
        UIBezierPath(ovalIn: breadthRect).addClip()
        UIImage(cgImage: cgImage, scale: 1, orientation: imageOrientation)
            .draw(in: breadthRect)
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}



enum BallDirection {
    case up
    case down
    case stopped
}
