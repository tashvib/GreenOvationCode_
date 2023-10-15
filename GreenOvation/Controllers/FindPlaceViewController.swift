import UIKit
import Firebase

class FindPlaceViewController: UIViewController {
    let db = Firestore.firestore()
    var preferencesArray = [""]
    @IBOutlet weak var tableViewForEvents: UITableView!
    //var nameOfEvents: [String] = ["cleanup1", "cleanup2", "cleanup3", "cleanup4", "cleanup5", "cleanup6", "cleanup7", "cleanup8", "cleanup9"]
    var nameOfEventWhenArrowPressed: String = ""
    var nameOfEvents: [String] = []
    var organizationNameArr: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("preferences array: \(preferencesArray)")

        tableViewForEvents?.delegate = self
        tableViewForEvents?.dataSource = self
        
        fetchLeaderboardData()
    }
    func fetchLeaderboardData() {
        db.collection("volunteeropportunities").getDocuments { [weak self] (querySnapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
                return
            }
            
            guard let documents = querySnapshot?.documents else {
                print("No matching documents")
                return
            }
            self?.nameOfEvents.removeAll()
            
            for document in documents {
                if let name = document["name"] as? String,
                   let organization = document["organization"] as? String,
                   let skill = document["skill"] as? String {
                    
                    // Check if the skill value from Firestore is in the preferencesArray
                    if self?.preferencesArray.contains(skill) == true {
                        self?.nameOfEvents.append(name)
                        self?.organizationNameArr.append(String(organization))
                    }
                }
            }
            
            self?.tableViewForEvents?.reloadData()
        }
    }


    
    
//    func fetchLeaderboardData() {
//        db.collection("volunteeropportunities").getDocuments { [weak self] (querySnapshot, error) in
//            if let error = error {
//                print("Error getting documents: \(error)")
//                return
//            }
//
//            guard let documents = querySnapshot?.documents else {
//                print("No matching documents")
//                return
//            }
//            self?.nameOfEvents.removeAll()
//
//            for document in documents {
//                if let name = document["name"] as? String, let organization = document["organization"] as? String{
//
//                    self?.nameOfEvents.append(name)
//                    self?.organizationNameArr.append(String(organization))
//                }
//            }
//
//            self?.tableViewForEvents?.reloadData()
//        }
//    }
    
    
    
    @IBAction func arrowPressed(_ sender: UIButton) {
//        K.findPlaceButtonID.buttonID =
           // self.performSegue(withIdentifier: "GoToDescription", sender: self)
        print("in the arrow button pressed")
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("in the prepare for segue")
        if segue.identifier == "GoToDescription" {
            // Check if the segue identifier matches the one you've set in the storyboard
            print("hello again")
            if let button = sender as? UIButton {
                // Access the button tag and pass it to the destination view controller
                let buttonTag = button.tag
                print("in prepare: \(buttonTag)")
                

                // Access the destination view controller
                if let destinationVC = segue.destination as? DescriptionViewController {
                    destinationVC.descriptionTextTitleText = button.title(for: .normal) ?? ""
                }
            }
        }
    }
    
}
extension FindPlaceViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nameOfEvents.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TableViewCellForEvents
        
        cell.nameOfEvent?.text = nameOfEvents[indexPath.row]
        cell.arrowButton.setTitle(nameOfEvents[indexPath.row], for: .normal)
        cell.organization?.text = organizationNameArr[indexPath.row]
        cell.arrowButton.tag = indexPath.row
        print("cell.arrowButton.tag: \(cell.arrowButton.tag)")
        
        return cell
    }
    private func tableView(_ tableView: UITableView, heightForHeaderInSection indexPath: IndexPath) -> CGFloat {
        return CGFloat(100.0/2)
    }
    private func tableView(_ tableView: UITableView, heightForFooterInSection indexPath: IndexPath) -> CGFloat {
        return CGFloat(100.0/2)
    }
}

//
//func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//    let cell = tableView.dequeueReusableCell(withIdentifier: "YourCellIdentifier", for: indexPath) as! YourTableViewCell
//
//    // Configure the cell...
//
//    cell.yourButton.tag = indexPath.row // Assign the row index as the button's tag value
//
//    return cell
//}
