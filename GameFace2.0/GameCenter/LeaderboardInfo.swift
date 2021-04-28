//Created for GameFace  (07.03.2021 )

import Foundation
import GameKit

struct LeaderboardInfo {
    let id: String
    let rank: Int
    let name: String
    let score: Int64
    var isLocal: Bool = false
    
    
    init(_ score: GKScore, _ localPlayer: GKScore?) {
        self.id = score.player.playerID
        self.rank = score.rank
        self.name = score.player.alias
        self.score = score.value
         
        if let lp = localPlayer, score.player.playerID == lp.player.playerID {
            self.isLocal = true
            
            /// update local storage
            saveScore(lp.value)
            print("ℹ️ Player local score updated to: \(lp.value)")
        }
        
    }
}




public func saveScore(_ score: Int64) {
    UserDefaults.standard.set(score, forKey: "game.myScore")
}


public func getMyScore() -> Int64 {
    Int64(UserDefaults.standard.integer(forKey: "game.myScore"))
}
 
enum RewardPoints: Int64 {
    /// Win = + 3 points
    case win
    
    /// Lose = + .5 points
    case lose
    
    /// Draw =  + .5 points for both players
    case draw
    
    
    var Int64Value: Int64 {
        switch self {
            case .win: return 30
            case .lose: return 5
            case .draw: return 5
        }
    } 
}



enum LeaderboardError: Error {
    case unknownError
    case connectionError
    case authError
}
