//
//  InviteFriends.swift
//  GameFace
//
//  Created by Eric.Fox on 12/7/20.
//  Copyright © 2020 Agora.io. All rights reserved.
//

import UIKit
import Swift

class InviteFriends: UIViewController {
    

    private let shareURLString = "https://ackermann.io/about"
   
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func urlShareButtonPressed(_ sender: UIButton) {
        guard let url = URL(string: shareURLString) else {
            return
        }
        
        let vc = VisualActivityViewController(url: url)
        vc.previewLinkColor = .magenta

        presentActionSheet(vc, from: sender)
    }

    private func presentActionSheet(_ vc: VisualActivityViewController, from view: UIView) {
        if UIDevice.current.userInterfaceIdiom == .pad {
            vc.popoverPresentationController?.sourceView = view
            vc.popoverPresentationController?.sourceRect = view.bounds
            vc.popoverPresentationController?.permittedArrowDirections = [.right, .left]
        }
        
        present(vc, animated: true, completion: nil)
    }


    
    
    
    
    
    
    
    
    
    
    
    
    
//   func presentShareSheet() {
//        guard let url = URL(string: "https://apps.apple.com/us/app/gameface-video-chat/id1462710737" ) else {
//            return
//        }
//        let shareSheetVC = UIActivityViewController(
//            activityItems: [
//            url
//            ],
//            applicationActivities: nil
//        )
//        present(shareSheetVC, animated: true)
//        }
}
