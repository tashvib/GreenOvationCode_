import UIKit
import Firebase

class FinishedVisionViewController: UIViewController {
    @IBOutlet weak var goToLeaderboard: UIButton!
    var numCorrect: Int = 0
    let db = Firestore.firestore()
    @IBOutlet weak var numEcopointsGainedTextView: UITextView!
    @IBOutlet weak var congratsTextView: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        congratsTextView.text = "Congrats on correctly identifying how to properly dispose of  \(numCorrect) / 5 items!"
        numEcopointsGainedTextView.text = "You have gained \(numCorrect*100) ecopoints. "
        K.Points.numPoints += numCorrect*100
        updatePoints()
        goToLeaderboard.layer.cornerRadius = 20
        goToLeaderboard.clipsToBounds = true
        goToLeaderboard.layer.masksToBounds = false
        goToLeaderboard.layer.shadowRadius = 10
        goToLeaderboard.layer.shadowOpacity = 1.0
        goToLeaderboard.layer.shadowOffset = CGSize(width: 3, height: 3)
        goToLeaderboard.layer.shadowColor = UIColor.lightGray.cgColor
        // Do any additional setup after loading the view.
    }
    
    func updatePoints()
        {

                print("update points method was run")
                
                if let currentUser = Auth.auth().currentUser?.email {
                    let query = db.collection(K.FStore.collectionName).whereField("currentUser", isEqualTo: currentUser)
                    
                    query.getDocuments { (querySnapshot, error) in
                        if let error = error {
                            print("Error getting documents: \(error)")
                            return
                        }
                        
                        guard let documents = querySnapshot?.documents else {
                            print("No matching documents")
                            return
                        }
                        
                        if documents.count == 1 {
                            let document = documents[0]
                            let documentID = document.documentID
                            
                            let userRef = self.db.collection(K.FStore.collectionName).document(documentID)
                            
                            userRef.updateData([
                                "numEcoPoints": K.Points.numPoints
                            ]) { error in
                                if let e = error {
                                    print("There was an issue updating data in Firestore, \(e)")
                                } else {
                                    print("Successfully updated data.")
                                }
                            }
                        } else {
                            print("Multiple matching documents found")
                        }
                    }
                }
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
