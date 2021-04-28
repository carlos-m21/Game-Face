//Created for GameFace  (09.03.2021 )

import UIKit

class LeaderboardViewController: UIViewController {

    @IBOutlet weak var leaderboardTableView: UITableView!
    @IBOutlet weak var errorLabel: UILabel!
 
    
    private var scoreList: [LeaderboardInfo] = []
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        fetchLeaderboard()
    }
    
      
    private func fetchLeaderboard() {
        showErr(with: nil)
        
        GCConnection.shared.loadScores { (leaderboard, err) in
            if let error = err {
                if let lbErr = error as? LeaderboardError {
                    switch lbErr {
                    case .authError:
                        self.showErr(with: "Press Connect to Log in to Game Center")
                    case .connectionError:
                        self.showErr(with: "Connection issue")
                    case .unknownError:
                        self.showErr(with: "Unknown Error")
                    }
                    
                } else {
                    self.showErr(with: error.localizedDescription)
                }
                
                print("❌ loadScores:", error)
            } else {
                self.scoreList = leaderboard
                self.update()
            }
        }
    }
    
    private func update() {
        print("ℹ️ UI: Leaderboard table start updating")
         
        leaderboardTableView.reloadData()
        if scoreList.count == 0 {showErr(with: "Leaderboard is empty")}
    }
    
    private func showErr(with text: String?) {
        
        if let t = text {
            errorLabel.text = t
            errorLabel.isHidden = false
            leaderboardTableView.isHidden = true
        } else {
            errorLabel.isHidden = true
            leaderboardTableView.isHidden = false
        }
    }
    
    
    @IBAction func close(sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
}


extension LeaderboardViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        scoreList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! LeaderboardTableViewCell
        cell.setup(cell: scoreList[indexPath.row])
        
        return cell
    }
}


class LeaderboardTableViewCell: UITableViewCell {
    
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var cellBackground: UIView!
    
    @IBOutlet weak var paddingTop: NSLayoutConstraint!
    @IBOutlet weak var paddingBottom: NSLayoutConstraint!
    
    func setup(cell data: LeaderboardInfo) {
        cellBackground.layer.cornerRadius = 10
        
        cellBackground.backgroundColor = data.isLocal ? #colorLiteral(red: 0.9450980392, green: 0.3960784314, blue: 0.1607843137, alpha: 1) :#colorLiteral(red: 0.9097141623, green: 0.9098667502, blue: 0.9096941352, alpha: 0.1032076198)
        
        paddingTop.constant = data.isLocal ? 10 : 4
        paddingBottom.constant = data.isLocal ? 10 : 4
        
        
        userNameLabel.text = "\(data.rank). \(data.name)"
        scoreLabel.text = "\(Float(data.score)/10)"
    }
}
