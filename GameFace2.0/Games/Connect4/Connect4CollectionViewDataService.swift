import UIKit

class Connect4CollectionViewDataService: NSObject , UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    let numberOfColumns = 7
    let maxNumberOfCountersPerColumn = 6
    
    fileprivate unowned let container: Connect4Container
    
    init(_ container: Connect4Container) {
        self.container = container
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numberOfColumns
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return maxNumberOfCountersPerColumn
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let reuseId = "cell"
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseId, for: indexPath) as! Connect4Cell
        
        let game = container.game
        
        let positionStatus = game.gameBoard.counterStatus(at: indexPath)
        switch positionStatus {
        case .empty:
            cell.imageView.image = #imageLiteral(resourceName: "EmptyCircle")
        case .red:
            cell.imageView.image = #imageLiteral(resourceName: "OrangeCircle")
        case .yellow:
            cell.imageView.image = #imageLiteral(resourceName: "WhiteCircle")
        case .gold:
            cell.imageView.image = #imageLiteral(resourceName: "GreenCircle")
        }
        cell.isUserInteractionEnabled = !(game.gameBoard.counterExists(at: indexPath))
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if ( container.game.winner == nil ) {
               
            let me: CounterColour =
                ( container.isHost && container.game.isHostFirst == true ) ||
                ( !container.isHost && container.game.isHostFirst == false )
                
                ? .yellow : .red
            
             
            if container.game.whoseGo != me {
                return
            }
            
            container.game.implementMove(
                at: indexPath
            )
            
            /// win
            if container.game.winner == me {
                if container.isHost {
                    container.game.hostScore += 1
                } else {
                    container.game.slaveScore += 1
                }
                
           
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        self.container.reset()
                    }
         
            }
            
             
            // draw
            if container.game.turnsTaken >= 42 {
                container.game.hostScore += 1
                container.game.slaveScore += 1
                
                
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        self.container.reset()
                 
                }
            }
             
            container.setScoresLabelText(container.game.hostScore, container.game.slaveScore)
             
            container.broadCastState()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        section == 0
        ? .zero
        : (
            collectionViewLayout as! UICollectionViewFlowLayout
        ).sectionInset
    }
}
