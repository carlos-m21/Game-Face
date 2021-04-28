import UIKit

final class TicTacToeContainer: UIView {
    fileprivate var ticTacToe = TicTacToe()
    
    fileprivate var broadCast: ((Data) -> ())?
    
    fileprivate var setStatusLabelText: ((TicTacToe.GameState) -> ())?
    fileprivate var isUILocked = false
    
    
    func setUp(
        broadCast: @escaping (Data) -> (),
        setStatusLabelText: @escaping (TicTacToe.GameState) -> ()
    ) {
        self.broadCast = broadCast
        self.setStatusLabelText = setStatusLabelText
        
        for subview in subviews {
            (
                subview as? UIButton
            )?.addTarget(
                self,
                action: #selector(TicTacToeContainer.buttonTapped(_:)),
                for: .touchUpInside
            )
        }
    }
    
    @IBAction func buttonTapped(_ sender: AnyObject) {
        
        guard !isUILocked else {  return }
        
        let boardIndices = self.boardIndices(
            buttonTag: sender.tag
        )
        
        if ( ticTacToe.board[
                boardIndices.0
            ][
                boardIndices.1
            ]
            != 0
        ) {
        
            return
                print ("did send data")
        }
        
        var btnBoardValue: Int
        switch ticTacToe.checkStatus().state {
        case .xTern:
            btnBoardValue = 1
        case .oTern:
            btnBoardValue = 2
            
            
            
        case .xWin, .oWin, .draw:
            btnBoardValue = 0
        }
        
        ticTacToe.board[boardIndices.0][boardIndices.1] = btnBoardValue
        
        broadCastState()
    }
    
    func updateState() {
        for i in 1...9 {
            let boardIndices = self.boardIndices(
                buttonTag: i
            )
            
            let buttonImageName: String
            
            switch (
                ticTacToe.board[
                    boardIndices.0
                ][
                    boardIndices.1
                ]
            ) {
            case 1:
                buttonImageName = "X_Box"
                
            case 2:
                buttonImageName = "Circle_Box"
                
            default:
                buttonImageName = "Blank_Box"
            }
            
            (
                viewWithTag(i)
                as! UIButton
            ).setImage(
                UIImage(
                    named: buttonImageName
                )!,
                for: .normal
            )
        }
        
        let check = ticTacToe.checkStatus()
        
        var winImage = ""
        
        switch check.state {
        case .xWin:
            winImage = "X_Green"
        case .oWin:
            winImage = "O_Green"
        case .draw, .oTern, .xTern:
            print("nothing to do")
        
        }
        
        
        ///
        if let board = check.board {
            for i in 1...9 {
                let boardIndices = self.boardIndices( buttonTag: i )
                
                switch (board[boardIndices.0][boardIndices.1]) {
                case 1:
                     
                    (viewWithTag(i) as! UIButton)
                        .setImage(UIImage(named: winImage)!, for: .normal)
                    
                default:
                    print("udef")
                }
            }
        }
        
        
        
        
        setStatusLabelText!(check.state)
    }
    
    fileprivate func boardIndices(buttonTag: Int) -> (Int, Int) {
        (
            (buttonTag-1)/3, (buttonTag-1)%3
        )
    }
    
    fileprivate func broadCastState() {
        updateState()
        
        broadCast!(
            try! JSONEncoder().encode(
                TicTacToeState(
                    board: ticTacToe.board,
                    isHostFirst: ticTacToe.isHostFirst,
                    scores: ticTacToe.scores
                )
            )
        )
    }
    
    func receiveBroadCast(_ message: Data) {
        if let ticTacToeState = try? JSONDecoder().decode(
            TicTacToeState.self,
            from: message
        ) {
            let expectedBoardSize = 3
            
            if (
                ( ticTacToeState.board.count == expectedBoardSize
                )
                && ticTacToeState.board.allSatisfy {
                    $0.count == expectedBoardSize
                }
            ) {
                ticTacToe.board = ticTacToeState.board
                ticTacToe.isHostFirst = ticTacToeState.isHostFirst
                
                updateState()
            }
        }
    }
    
    func reset() {
        ticTacToe.resetBoard()
        broadCastState()
    }
    
    
    func isHostFirst() -> Bool { // X
        ticTacToe.isHostFirst
    }
    
    func getScores() -> [Int] {
        return ticTacToe.scores
    }
    
    func addScore(_ to: Int) {
        ticTacToe.scores[to] += 1
    }
    
    
    func lockUI(_ lock:Bool) {
        self.isUILocked = lock
    }
}




struct TicTacToeState: Codable {
    let board: [[Int]]
    let isHostFirst: Bool
    let scores: [Int]
}
