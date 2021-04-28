//
//  TicTacToe.swift
//  TicTacToe
//
//  Created by gauravds on 28/01/17.
//  Copyright © 2017 gauravds All rights reserved.
//

// default position = 0
// assume x is first player with value 1
// assume O is second player with value 2
class TicTacToe {

    public enum GameState : String {
        case xTern = "Turn: X"
        case oTern = "Turn: O"
        case draw = "Game Draw"
        case xWin = "X Wins"
        case oWin = "O Wins"
    }
    
    
    public var scores = [0,0]
    public var board = [[Int]](repeating: [Int](repeating: 0, count: 3), count: 3)
    public var isHostFirst = true
    
    
    
    public func resetBoard() {
        board = [[Int]](repeating: [Int](repeating: 0, count: 3), count: 3)
        isHostFirst = Bool.random()
        
        if scores[0] >= AppConst.pointsToWin ||  scores[1] >= AppConst.pointsToWin {
            scores = [0,0]
        }
    }
      
    private let winningBoard = [
                                [[1,1,1],[0,0,0],[0,0,0]],
                                [[0,0,0],[1,1,1],[0,0,0]],
                                [[0,0,0],[0,0,0],[1,1,1]],

                                [[1,0,0],[1,0,0], [1,0,0]],
                                [[0,1,0],[0,1,0], [0,1,0]],
                                [[0,0,1],[0,0,1], [0,0,1]],

                                [[1,0,0],[0,1,0], [0,0,1]],
                                [[0,0,1],[0,1,0], [1,0,0]],
                                ]

    public func checkStatus() -> ( state: GameState, board: [[Int]]?) {
        
        let user1 = checkForWinner(val: 1)
        let user2 = checkForWinner(val: 2)
        
        if user1.status { // x
            return (.xWin, user1.board)
        } else if user2.status { // O
             
            return (.oWin, user2.board)
        } else {
            var xCount = 0, oCount = 0, dotCount = 0
            for i in 0..<3 {
                for j in 0..<3 {
                    switch board[i][j] {
                    case 1: // x
                        xCount += 1
                    case 2: // O
                        oCount += 1
                    default:
                        dotCount += 1
                    }
                }
            }

            if dotCount == 0 {
                
                
                return (.draw, nil)
            } else if xCount > oCount {
                return (.oTern, nil)
            } else {
                return (.xTern, nil)
            }
        }
    }

    private func checkForWinner(val: Int) -> (status: Bool, board: [[Int]]?) {
        var counter = 0
        
        var winBoard = [[Int]](repeating: [Int](repeating: 0, count: 3), count: 3)
         
        for wBoard in winningBoard {
            counter = 0
            for i in 0..<3 {
                for j in 0..<3 {
                    if wBoard[i][j] == 1 {
                        if board[i][j] == val {
                            counter += 1
                              
                                for iw in 0..<3 {
                                     
                                        if
                                            wBoard[iw][2] == (board[iw][2] == val ? 1 : 0) &&
                                            wBoard[iw][1] == (board[iw][1] == val ? 1 : 0) &&
                                            wBoard[iw][0] == (board[iw][0] == val ? 1 : 0)
                                        {
                                            winBoard = wBoard
                                        }
                                   
                                } 
                        }
                    }
                }
            }
            
            if (counter == 3) {
                /// found a win combination
                 
                 print(winBoard)
                return (true, winBoard)
            }
        }
        return (false, nil)
    }
}
