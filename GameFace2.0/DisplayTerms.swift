//
//  DisplayTerms.swift
//  GameFace
//
//  Created by Eric.Fox on 4/29/20.
//
//

import UIKit
import WebKit

class DisplayTerms: UIViewController {

    @IBOutlet weak var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
 
        /// Try load to load TOS form URL
        loadTerms()
    }
     
    private func loadTerms() {
        guard let url = URL(string:"https://www.gamefaceapp.com/terms-of-use-agreement") else { return }
        
        let tosRequest = URLRequest(url: url)
        
        webView.load(tosRequest)
        
    }
}
