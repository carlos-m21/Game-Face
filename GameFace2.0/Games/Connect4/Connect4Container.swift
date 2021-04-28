import UIKit
import GameKit

final class Connect4Container: UICollectionView  {
    var game = Connect4Game()
    
    var dataService : Connect4CollectionViewDataService!
    
    fileprivate let flowLayout = UICollectionViewFlowLayout()
    
    fileprivate let broadCast: (Data) -> ()
    
    fileprivate let setStatusLabelText: (Int) -> ()
    let setScoresLabelText: (Int, Int) -> () // host - slave
    
    
    fileprivate var lastBoundsSize: CGSize?
    
    var isHost: Bool = false
    
    init(isHost: Bool,
         broadCast: @escaping (Data) -> (),
         setStatusLabelText: @escaping (Int) -> (),
         setScoresLabelText: @escaping (Int, Int) -> ()
    ) {
        
        self.isHost = isHost
        self.broadCast = broadCast
        
        self.setStatusLabelText = setStatusLabelText
        self.setScoresLabelText = setScoresLabelText
        
        super.init(
            frame: .zero,
            collectionViewLayout: flowLayout
        )
        
        backgroundColor = .clear
        
        register(
            Connect4Cell.self,
            forCellWithReuseIdentifier: "cell"
        )
        
        setUpDataService()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let boundsSize = bounds.size
        
        if lastBoundsSize != boundsSize {
            lastBoundsSize = boundsSize
            
            let availableWidth = boundsSize.width
            
            let numberOfItemsPerRow: CGFloat = 7
            
            let itemSize = round(
                (availableWidth * 0.75)
                / numberOfItemsPerRow
            )
            
            flowLayout.itemSize = CGSize(
                width: itemSize,
                height: itemSize
            )
            
            let itemSpacing = floor(
                (
                    availableWidth
                    - itemSize * numberOfItemsPerRow
                )
                / (numberOfItemsPerRow - 1)
            )
            
            flowLayout.minimumInteritemSpacing = itemSpacing
            
            flowLayout.sectionInset = UIEdgeInsets(
                top: itemSpacing,
                left: 0,
                bottom: 0,
                right: 0
            )
            
            flowLayout.invalidateLayout()
        }
    }
    
    func receiveBroadCast(_ message: Data) {
        if let game = try? JSONDecoder().decode(
            Connect4Game.self,
            from: message
        ) {
            self.game = game
              
            self.setScoresLabelText(game.hostScore, game.slaveScore)
            self.update()
        }
    }
    
    func reset() {
        var nextGame = Connect4Game()
        nextGame.isHostFirst = Bool.random()
        nextGame.hostScore = game.hostScore
        nextGame.slaveScore = game.slaveScore
         
        
        // reset scores when anybody is win
        if nextGame.hostScore >= AppConst.pointsToWin || nextGame.slaveScore >= AppConst.pointsToWin {
            nextGame.hostScore = 0
            nextGame.slaveScore = 0
        }

        
        game = nextGame
         
        broadCastState()
    }
    
    
    func update() {
        
         
        
        let me: CounterColour =
            ( isHost && game.isHostFirst == true ) ||
            ( !isHost && game.isHostFirst == false )
            ? .yellow : .red
        
          
        //return 0 when host turn, 1 - slave
        self.setStatusLabelText((game.whoseGo == me) && isHost ? 0 : 1)
        reloadData()
    }
    
     
    
    
    
    func broadCastState() {
        update()
        
        broadCast( try! JSONEncoder().encode( game ) )
        
        
    }
    
    fileprivate func setUpDataService() {
        dataService = Connect4CollectionViewDataService(
            self
        )
        
        delegate = dataService
        dataSource = dataService
    }
}
