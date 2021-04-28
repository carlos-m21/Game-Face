enum Game: String, CaseIterable, Hashable {
    
    var playerGroup: Int {
        switch self {
    
        case .ticTacToe:
            return 1
            
        case .connect4:
            return 2
            
        case .pong:
            return 3
        }
    }
    
    case ticTacToe = "TicTacToe"
    
    case connect4 = "Connect4"
    
    case pong = "Pong"
    
    init?(playerGroup: Int) {
        switch playerGroup {
        case 1:
            self = .ticTacToe
            
        case 2:
            self = .connect4
            
        case 3:
            self = .pong
            
        default:
            return nil
        }
    }
}
