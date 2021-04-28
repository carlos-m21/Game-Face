import Foundation

struct Connect4Game: Codable {
    
    enum directions : Int, Codable {
        case northEast = 0
        case east
        case southEast
        case south
        case southWest
        case west
        case northWest
    }
    
    let offset: [BoardPosition]
    var turnsTaken : Int
    var whoseGo: CounterColour
    var gameBoard: Board
    
    var winner: CounterColour??
    
    var isHostFirst: Bool // white
    var hostScore: Int
    var slaveScore: Int
    
    init() {
        offset = [BoardPosition(column:1, row:1),BoardPosition(column:1, row:0),BoardPosition(column:1 , row:-1),BoardPosition(column:0 , row:-1),BoardPosition(column:-1,row:-1),BoardPosition(column: -1, row:0),BoardPosition(column:-1 , row:1)]
        turnsTaken = 0
        hostScore = 0
        slaveScore = 0
        
        whoseGo = CounterColour.yellow
        gameBoard = Board()
        isHostFirst = Bool.random()
    }
    
    func getPlayerNames() -> [String]{
        return ["White", "Red"]
    }
    
    
    mutating func implementMove(at indexPath: IndexPath){
        turnsTaken += 1
        let counter = PlayingCounter(colour: whoseGo)
        let newPosition = self.drillDown(at: indexPath)
        refreshBoardWith(counter: counter, at: newPosition)
        let win = checkForWin(from: newPosition, colour: counter.colour)
        if win == true {
            handleWin(counter: counter)
        } else {
            if turnsTaken >=  42 {
                handleDraw()
            } else{
                if whoseGo == .yellow {
                    whoseGo = .red
                } else {
                    whoseGo = .yellow
                }
            }
        }
    }
    mutating func handleDraw(){
        winner = .some( nil )
    }
    mutating func handleWin(counter: PlayingCounter ) {
        winner = counter.colour
          
    }
    mutating func refreshBoardWith(counter playingCounter: PlayingCounter, at position: BoardPosition){
        gameBoard.columns[position.column].add(playingCounter)
    }
    mutating func checkForWin(from position : BoardPosition, colour :CounterColour) -> Bool {
        
        let southWin = (countConsecuticeCountersOf(colour: colour, from: position, inDirection: offset[directions.south.rawValue]) >= 3)
        if southWin == true {
            changeToGoldStar(at: position)
            highlightWinningCountersOf(colour: colour, from: position, inDirection: offset[directions.south.rawValue])
        }
        
        let eastWestWin = (countConsecuticeCountersOf(colour: colour, from: position, inDirections1: offset[directions.west.rawValue], and2: offset[directions.east.rawValue]) >= 3)
        
        if eastWestWin == true {
            changeToGoldStar(at: position)
            highlightWinningCountersOf(colour: colour, from: position, inDirection1: BoardPosition(column: -1, row: 0 ),and2:BoardPosition(column: 1, row: 0 ))
        }
        let fallingWin = (countConsecuticeCountersOf(colour: colour, from: position, inDirections1: offset[directions.northWest.rawValue], and2: offset[directions.southEast.rawValue]) >= 3)
        
        
        if fallingWin == true {
            changeToGoldStar(at: position)
            highlightWinningCountersOf(colour: colour, from: position, inDirection: BoardPosition(column: -1, row: 1 ))
            highlightWinningCountersOf(colour: colour, from: position, inDirection: BoardPosition(column: 1, row: -1 ))
        }
        let risingWin = (countConsecuticeCountersOf(colour: colour, from: position, inDirections1: offset[directions.southWest.rawValue], and2: offset[directions.northEast.rawValue]) >= 3)
        
        
        if risingWin == true {
            changeToGoldStar(at: position)
            highlightWinningCountersOf(colour: colour, from: position, inDirection: BoardPosition(column: -1, row: -1 ))
            highlightWinningCountersOf(colour: colour, from: position, inDirection: BoardPosition(column: 1, row: 1 ))
        }
        return (southWin || eastWestWin || fallingWin || risingWin)
    }
    func countConsecuticeCountersOf(colour: CounterColour, from current: BoardPosition, inDirections1 offset1: BoardPosition, and2 offset2: BoardPosition) -> Int{
        
        return countConsecuticeCountersOf(colour: colour, from: current, inDirection: offset1)
            + countConsecuticeCountersOf(colour: colour, from: current, inDirection: offset2)
    }
    
    func countConsecuticeCountersOf(colour : CounterColour, from current: BoardPosition, inDirection offset: BoardPosition) -> Int{
        let theCounterStatus : PositionStatus = colour == .yellow ? .yellow : .red
        guard let newPosition = generateNewPosition(from: current, inDirection: offset) else { return 0 }
        guard gameBoard.counterExists(at: newPosition) else { return 0 }
        guard gameBoard.counterStatus(at: newPosition) ==  theCounterStatus else { return 0 }
        
        return 1 + countConsecuticeCountersOf(colour: colour, from: newPosition, inDirection: offset)
    }
    
    mutating func highlightWinningCountersOf(colour: CounterColour, from current: BoardPosition, inDirection1  offset1: BoardPosition, and2 offset2: BoardPosition) {
        highlightWinningCountersOf(colour: colour, from: current, inDirection: offset1)
        highlightWinningCountersOf(colour: colour, from: current, inDirection: offset2)
    }
    
    mutating func highlightWinningCountersOf(colour: CounterColour, from current: BoardPosition, inDirection offset: BoardPosition) {
        let theCounterStatus : PositionStatus = colour == .yellow ? .yellow : .red
        guard let newPosition = generateNewPosition(from: current, inDirection: offset) else { return}
        guard gameBoard.counterExists(at: newPosition) else { return }
        guard gameBoard.counterStatus(at: newPosition) ==  theCounterStatus else { return  }
        
        changeToGoldStar(at: newPosition)
        highlightWinningCountersOf(colour: colour, from: newPosition, inDirection: offset)
    }
    mutating func changeToGoldStar(at position:BoardPosition){
        gameBoard.columns[position.column].counters[position.row].colour = .gold
    }
    func generateNewPosition(from current: BoardPosition, inDirection offset: BoardPosition ) -> BoardPosition?{
        let newPosition = BoardPosition(column: current.column + offset.column, row: current.row + offset.row)
        if positionIsValidBoardPosition(newPosition) == true {
            return newPosition
        }
        return nil
    }
    
    func positionIsValidBoardPosition(_ newPosition:BoardPosition) -> Bool  {
        if newPosition.column < 0 || newPosition.column > 6 || newPosition.row < 0  || newPosition.row > 5 {
            return false
        }else {
            return true
        }
    }
    
    func drillDown(at indexPath: IndexPath) -> BoardPosition{
        let position = Connect4CoordinateConverter.modelPosition(for: indexPath)
        let column = (position.column)
        let newPosition = BoardPosition(column: column, row:gameBoard.columns[column].counters.count)
        return newPosition
    }
}
