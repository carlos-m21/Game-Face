//
//  GCConnection.swift
//  GCConnection


import Foundation
import UIKit
import GameKit

public enum AuthStatus{
    case undef
    case ok(localPlayer : GKLocalPlayer)
    case loginRequired(viewController : UIViewController)
    case error(err : Error)
    case loginCancelled
}

public protocol AuthHandler{
    func handle(connection : GCConnection, authStatusChanged : AuthStatus)
}

public class GCConnection{
    
    private var _currentMatch : Match? = nil
    
    private let leaderboardID = "com.scores.gameface"
    private var leaderboard: GKLeaderboard? = nil
    
    
    private static var _default = GCConnection()
    public static var shared : GCConnection{
        get{
            return ._default
        }
    }
    
    public var authHandler : AuthHandler?{
        didSet{
            DispatchQueue.main.async {
                self.authHandler?.handle(connection: self, authStatusChanged: self.authStatus)
            }
        }
    }
    
    public var authenticated : Bool{
        switch self.authStatus {
        case .ok( _):
            return true
        default:
            return false
        }
    }
    
    public var authStatus : AuthStatus = .undef
    
    public var activeMatch : Match?{
        get{
            guard let cm = _currentMatch else{
                return nil
            }
            
            switch cm.state {
            case .disconnected(_):
                _currentMatch = nil
                return _currentMatch
            default:
                // none
                return _currentMatch
            }
            
        }
    }
    
    fileprivate func log(_ items : Any...){
        let itemString = items.map { String(describing: $0) }.joined(separator: " ")
        print(itemString)
    }
    
    public func authenticate(){
        let localPlayer = GKLocalPlayer.local
        
        localPlayer.authenticateHandler = { (controller, error) in
            
            if let error = error{
                if let gkErr = error as? GKError{
                    if gkErr.code == GKError.Code.cancelled {
                        self.authStatus = .loginCancelled
                    } else{
                        self.authStatus = .error(err: error)
                    }
                }
                else{
                    self.authStatus = .error(err: error)
                }
            }
            else if localPlayer.isAuthenticated{
                self.authStatus = .ok(localPlayer: localPlayer)
            }
            else if let controller = controller {
                self.authStatus = .loginRequired(viewController: controller)
            }
            else{
                self.authStatus = .undef
            }
            
            DispatchQueue.main.async {
                self.authHandler?.handle(connection: self, authStatusChanged: self.authStatus)
            }
        }
    }
    
    func findMatch(_ game: Game?, minPlayers: Int, maxPlayers: Int) throws -> Match{
        let defaultTimeout : DispatchTime = .now() + .seconds(60)
        
        let result = try findMatch(
            game,
            minPlayers: minPlayers,
            maxPlayers: maxPlayers,
            withTimeout: defaultTimeout
        )
        
        return result
    }
    
    func findMatch(_ game: Game?, minPlayers: Int, maxPlayers: Int, withTimeout : DispatchTime) throws -> Match{
        if activeMatch != nil {
            throw createError(withMessage: "There is already an active match")
        }
        
        let request = GKMatchRequest()
        request.minPlayers = minPlayers
        request.maxPlayers = maxPlayers
        
        request.playerGroup = (
            game?.playerGroup ?? 0
        )
        
        print("playerGroup: \(request.playerGroup)")
        
        let result = Match(rq: request, matchMaker: GKMatchmaker.shared())
        result.find(timeout: withTimeout)
        
        _currentMatch = result
        
        return result
    }
    
    /// MARK:  Leaderboard functionality
    
    func updateScore(game value: RewardPoints, result: @escaping (_ err: Error?) -> Void) {
         
        let score = GKScore(leaderboardIdentifier: self.leaderboardID)
        
        let myTotal: Int64 = getMyScore()+value.Int64Value
        print("Try to update score to: ", myTotal)
        saveScore(myTotal)
        
        score.value = Int64(myTotal)
        
        GKScore.report([score]) { (error) in
            if let err = error {
                result(err)
            } else {
                result(nil)
            }
        }
    }
    
    
    /// Get Leaderboard from Game Center
    /// -Return: Sorted by rank
    func loadScores(finished: @escaping (_ scores: [LeaderboardInfo], _ error: Error?) -> Void) {
        fetchLeaderboard { (err) in
              
            if let er = err {
                finished([], er)
            } else if let lb = self.leaderboard {
                lb.playerScope = .global
                  
                
                lb.loadScores { (sc, error) in
                    if let err = error {
                        finished([], err)
                    } else if let scores = sc {
                        var leaderboard = scores.map {LeaderboardInfo($0, lb.localPlayerScore)}
                         
                        /// Sorting  local first then sort by rank
                        leaderboard.sort {
                            if $0.isLocal && !$1.isLocal {
                                    return true //this will return true: $0 is priority, $1 is not
                                }
                                if !$0.isLocal && $1.isLocal {
                                    return false //this will return false: $1 is priority, $0 is not
                                }
                                if $0.isLocal == $1.isLocal {
                                    return $0.rank < $1.rank //if both save the same priority, then return depending on the ordering value
                                }
                                return false
                        }
                        
                        finished(leaderboard, nil)
                    } else {
                        finished([], nil)
                        print("ℹ️ Leaderboard is empty")
                    }
                }
                 
            } else {
                /// no errors, no leaderboards
                finished([], nil)
                print("❌ loadScores failed (undef): no errors, no leaderboards")
            }
        }
    }
    
    
    func loadAvatar(for player: GKPlayer, result: @escaping (UIImage?) -> Void) {
        player.loadPhoto(for: .small) { (image, error) in
             
            if let err = error {
                print("❌ GC: Can't load player image. ERR: \(err)")
                result(nil)
            } else {
                result(image)
            }
        }
    }
    
    
    private func fetchLeaderboard(finished: @escaping (_ err: Error?) -> Void) {
        
        switch authStatus {
        case .ok(let player):
             
            print(player.playerID)
            
            /// Load LB from GC
            GKLeaderboard.loadLeaderboards() {[weak self] (leaderboards, err) in
                if let er = err {
                    
                    print("ℹ️ Leaderboard err:", er.localizedDescription)
                } else if let ldrbrds = leaderboards,
                          let leaderboard = ldrbrds.first(where: {$0.identifier == self?.leaderboardID}) {
                    
                    self?.leaderboard = leaderboard
                    finished(nil)
                } else {
                    print("ℹ️ Leaderboard undef error or can't find leaderboard !")
                }
            }
        
        case .error(let err):
            finished(err)
        
        case .loginRequired(_), .loginCancelled:
             
            finished(LeaderboardError.authError)
        
        case .undef:
            finished(LeaderboardError.unknownError)
    
        }
         
        
//        switch self.authStatus {
//        case .error(err: err):
//            print(err)
//        }
    }
    
}
public enum DisconnectedReason{
    case matchEmpty
    case matchMakingTimeout
    case cancel
    case error
}
enum MatchState{
    case pending
    case connected(Game, isHost: Bool)
    case disconnected(reason : DisconnectedReason)
}
protocol MatchHandler{
    func handle(_ error : Error)
    func handle(_ state : MatchState)
    func handle(data : Data, fromPlayer : GKPlayer)
    func handle(rematch: Bool, fromPlayer : GKPlayer)
    func handle(playerDisconnected : GKPlayer)
}

public class Match : NSObject, GKMatchDelegate {
    fileprivate var _request : GKMatchRequest
    fileprivate var _matchMaker : GKMatchmaker
    fileprivate var _match : GKMatch?
    
    var state : MatchState = .pending
    
    var handler : MatchHandler? {
        didSet{
            DispatchQueue.main.async {
                self.handler?.handle(self.state)
            }
        }
    }
    
    public var players : [GKPlayer] {
        get{
            guard let p = self._match?.players else {
                return []
            }
            
            return p
        }
    }
    
    fileprivate(set) var decisionMakerID: String?
    
    private func updateState(_ newState : MatchState){
        self.state = newState
        DispatchQueue.main.async {
            self.handler?.handle(self.state)
        }
    }
    
    private func error(_ err : Error){
        if err is GKError && (err as! GKError).code == GKError.Code.cancelled{
            return
        }
        
        DispatchQueue.main.async {
            self.handler?.handle(err)
        }
        self.cancelInternal(reason: .error)
    }
    
    init(rq : GKMatchRequest, matchMaker : GKMatchmaker){
        self._request = rq
        self._matchMaker = matchMaker
        super.init()
    }
    
    fileprivate func find(timeout : DispatchTime) {
        DispatchQueue.main.asyncAfter(deadline: timeout, execute: {
            switch self.state{
                case .pending:
                    self.cancelInternal(reason: .matchMakingTimeout)
                default:
                return
            }
            
            
            
        })
        
        self.state = .pending
        self._matchMaker.findMatch(for: self._request) { (match, err) in
            if let err = err {
                self.error(err)
            }
            else if let match = match {
                self._match = match
                self._match!.delegate = self
            }
            else{
                self.error(createError(withMessage: "received unexpected nil match"))
            }
        }
    }
    
    fileprivate func initPlayers() {
        guard let match = self._match else{
            return
        }
        
        GKMatchmaker.shared().finishMatchmaking(for: match)
        
        let localPlayer = GKLocalPlayer.local
        
        let decisionMaker = (
            match.players
            + [localPlayer]
        ).map {
            ($0, $0.playerID)
        }.min {
            $0.1 < $1.1
        }!.0
        
        decisionMakerID = decisionMaker.playerID
        
        if decisionMaker === localPlayer {
            let selected = (
                Game(
                    playerGroup: _request.playerGroup
                )
                ?? Game.allCases.randomElement()!
            )
            
            do {
                try publishMessage(
                    kind: "gameSelection",
                    payload: selected.rawValue
                )
            } catch {
                self.error(
                    error
                )
            }
            
            updateState(
                .connected(
                    selected,
                    isHost: true
                )
            )
        }
    }
     
    
    public func match(_ match: GKMatch, player: GKPlayer, didChange state: GKPlayerConnectionState){
        guard self._match == match else {
            return
        }
        
        switch state {
        case .connected where self._match != nil && match.expectedPlayerCount == 0:
            initPlayers()
        case .disconnected:
            DispatchQueue.main.async {
                self.handler?.handle(playerDisconnected: player)
            }
            
            if match.players.count == 0{
                self.cancelInternal(reason: .matchEmpty)
            }
        default:
            break
        }
    }
    
    public func match(_ match: GKMatch, didReceive data: Data, fromRemotePlayer player: GKPlayer) {
        DispatchQueue.main.async {
            do {
                let message = try JSONDecoder().decode(
                    [String: String].self,
                    from: data
                )
                
                guard let payload = message["payload"] else {
                    throw MatchReceivedMessageError.missingPayload
                }
                
                switch message["kind"] {
                case "gameSelection":
                    guard let game = Game(
                        rawValue: payload
                    ) else {
                        throw MatchReceivedMessageError.invalidGameName(
                            payload
                        )
                    }
                    
                    self.updateState(
                        .connected(
                            game,
                            isHost: false
                        )
                    )
                    
                case "broadCast":
                    guard let payloadData = Data(
                        base64Encoded: payload
                    ) else {
                        throw MatchReceivedMessageError.invalidDataPayload(
                            payload
                        )
                    }
                       
                    self.handler?.handle(
                        data: payloadData,
                        fromPlayer: player
                    )
                    
                case "requestRematch":
                    if payload == "1" {
                        self.handler?.handle(rematch: true, fromPlayer: player)
                    } else {
                        throw MatchReceivedMessageError.invalidDataPayload( payload )
                    }
                     
                case let kind:
                    throw MatchReceivedMessageError.invalidKind( kind )
                }
            } catch {
                self.error(
                    error
                )
            }
        }
    }
    
    public func match(_ match: GKMatch, didFailWithError error: Error?) {
        guard self._match == match else {
            return
        }
        
        guard let error = error else{
            return
        }
        
        self.error(error)
    }
    
    public func broadCast(data : Data, withMode : GKMatch.SendDataMode) throws {
        switch self.state {
        case .connected:
            try publishMessage(
                kind: "broadCast",
                payload: data.base64EncodedString(),
                withMode
            )
        default:
            return
        }
    }
    
    public func requestRematch(withMode : GKMatch.SendDataMode) throws {
        switch self.state {
        case .connected:
            try publishMessage(
                kind: "requestRematch",
                payload: "1",
                withMode
            )
        default:
            return
        }
    }
    
    
    
    
    fileprivate func publishMessage(kind: String, payload: String, _ mode: GKMatch.SendDataMode = .reliable) throws {
        try _match?.sendData(
            toAllPlayers: try! JSONEncoder().encode(
                [
                    "kind": kind,
                    "payload": payload
                ]
            ),
            with: mode
        )
    }
    
    private func cancelInternal(reason : DisconnectedReason){
        self._matchMaker.cancel()
        if let match = self._match {
            self._match = nil
            match.disconnect()
        }
        
        self.updateState(.disconnected(reason: reason))
    }
    
    public func cancel(){
        cancelInternal(reason: .cancel)
    }
    
}

fileprivate func createError(withMessage: String) -> Error{
    let err = NSError(domain: "GCConnection", code: 2, userInfo: [ NSLocalizedDescriptionKey: "received unexpected nil match"])
    return err
}

enum MatchReceivedMessageError: Error {
    case missingPayload
    
    case invalidGameName(String)
    
    case invalidDataPayload(String)
    
    case invalidKind(String?)
}
