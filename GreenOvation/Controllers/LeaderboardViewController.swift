import UIKit
import Firebase

class LeaderboardViewController: UIViewController {
    
    let db = Firestore.firestore()
    var usernames: [String] = []
    var pointsArr: [String] = []
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        print("viewdidload for leaderboard is hit")
        tableView.delegate = self
        tableView.dataSource = self
        
        //fetchLeaderboardData()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchLeaderboardData()
    }

    
    func fetchLeaderboardData() {
        print("fetchLeaderboardData is triggered")
        db.collection(K.FStore.collectionName).getDocuments { [weak self] (querySnapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
                return
            }
            
            guard let documents = querySnapshot?.documents else {
                print("No matching documents")
                return
            }
            
            self?.usernames.removeAll()
            self?.pointsArr.removeAll()

            // Create a temporary array to hold the user data.
            var users: [(username: String, numEcoPoints: Int)] = []

            for document in documents {
                if let username = document["username"] as? String,
                   let numEcoPoints = document["numEcoPoints"] as? Int {
                    users.append((username: username, numEcoPoints: numEcoPoints))
                }
            }

            // Sort the array in descending order.
            users.sort(by: { $0.numEcoPoints > $1.numEcoPoints })

            for user in users {
                self?.usernames.append(user.username)
                self?.pointsArr.append(String(user.numEcoPoints) + "🌱")
            }
            
            self?.tableView.reloadData()
        }
    }
}

extension LeaderboardViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("inside leaderboard extension")
        return usernames.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("pointsArr: \(pointsArr)")
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TableViewCell
        
        cell.username?.text = usernames[indexPath.row]
        cell.points?.text = pointsArr[indexPath.row]
        
        return cell
    }
}
