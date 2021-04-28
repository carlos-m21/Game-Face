//
//  Connect4Model.swift
//  Connect4
//
//  Created by Eric.Fox on 3/24/18.
//  Copyright © 2018 GameFace, LLC. All rights reserved.
//

import Foundation

let maxCountersPerRow = 6

enum CounterColour :Int, Codable {
    case yellow = 0
    case red
    case gold
}
enum PositionStatus{
    case empty
    case yellow
    case red
    case gold
}


struct PlayingCounter: Codable {
    var colour : CounterColour
}

struct Column: Codable {
    var counters = [PlayingCounter]()
    
    mutating func add(_ counter : PlayingCounter){
        guard counters.count < maxCountersPerRow else {return}
        counters.append(counter)
    }
}
struct BoardPosition: Codable {
    var column: Int
    var row: Int
}

struct Board: Codable {
    var columns = [Column]()
    init() {
        for _ in 1...7 {
            columns.append(Column())
        }
    }
    
    
    func counterExists(at position: BoardPosition) -> Bool {
        if self.columns[position.column].counters.count > (position.row) {
            return true
        }
        return false
    }
    
    func counterExists(at indexPath : IndexPath) -> Bool {
        let position = Connect4CoordinateConverter.modelPosition(for: indexPath)
        return counterExists(at: position)
    }
    
    func counter(at position : BoardPosition) -> PlayingCounter {
        return columns[position.column].counters[position.row]
    }
    func counter(at indexPath : IndexPath) -> PlayingCounter{
        let position = Connect4CoordinateConverter.modelPosition(for: indexPath)
        return counter(at: position)
    }
    
    func counterStatus(at position: BoardPosition) -> PositionStatus {
        guard (counterExists(at: position) == true) else {return .empty}
        let counter = self.counter(at: position)
        if counter.colour == .red {
            return .red
        }else if counter.colour == .yellow{
            return .yellow
        }else if counter.colour == .gold{
            return .gold
        }
        return .empty
    }
    
    func counterStatus(at indexPath : IndexPath) -> PositionStatus {
        let position = Connect4CoordinateConverter.modelPosition(for: indexPath)
        return counterStatus(at: position)
    }
    
    
}
