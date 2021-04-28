import UIKit




fileprivate var menuScreenRetainerRetaineeObjectAssociationKey: UInt8 = 0

func menuScreen(initiallySelected: Game?, didSelect: @escaping (Game?) -> ()) -> UIView {
    func retain<Retainee, Retainer: NSObject>(_ retianee: Retainee, from retainer: Retainer) {
        objc_setAssociatedObject(
            retainer,
            &menuScreenRetainerRetaineeObjectAssociationKey,
            retianee,
            .OBJC_ASSOCIATION_RETAIN_NONATOMIC
        )
    }
    
    let menuScreen = (
        Bundle.main.loadNibNamed(
            "MenuScreen",
            owner: nil,
            options: nil
        )!.first!
        as! UIView
    )
    
    let gameButtonsWithGames = Array(
        zip(
            menuScreen.subviews.lazy.compactMap {
                $0 as? UIButton
            },
            (
                [nil]
                + Game.allCases.map {
                    $0
                }
            )
        )
    )
    
    let leaderBoardButton = menuScreen.subviews.first { $0.tag == 999} as? UIButton
    
    leaderBoardButton?.addTarget(nil, action: #selector(PlayScreenViewController.pushLeaderboard), for: .touchUpInside)
    
    
    let updater = GameButtonsUpdater(
        gameButtonsWithGames: gameButtonsWithGames
    )
    
    retain(
        updater,
        from: menuScreen
    )
    
    for (gameButton, game) in gameButtonsWithGames {
        let gameButtonDidPressHandler = GameButtonDidPressHandler { [unowned updater] in
            didSelect(game)
            
            updater.update(selected: game)
        }
        
        gameButton.addTarget(
            gameButtonDidPressHandler,
            action: #selector(GameButtonDidPressHandler.didPress),
            for: .touchUpInside
        )
        
        retain(
            gameButtonDidPressHandler,
            from: gameButton
        )
    }
    
    updater.update(
        selected: initiallySelected
    )
    
   
    
    return menuScreen
}

fileprivate final class GameButtonsUpdater {
    fileprivate let gameButtonsWithGames: [(UIButton, Game?)]
    
    fileprivate init(gameButtonsWithGames: [(UIButton, Game?)]) {
        self.gameButtonsWithGames = gameButtonsWithGames
    }
    
    fileprivate func update(selected: Game?) {
        for (gameButton, game) in gameButtonsWithGames {
            gameButton.alpha = (
                game == selected
                ? 1
                : 0.5
            )
        }
    }
}


fileprivate final class GameButtonDidPressHandler: NSObject {
    fileprivate let handle: () -> ()
    
    fileprivate init(handle: @escaping () -> ()) {
        self.handle = handle
    }
    
    @objc fileprivate func didPress() {
        handle()
    }
}
