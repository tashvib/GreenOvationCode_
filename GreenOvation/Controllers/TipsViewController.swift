import UIKit
import Firebase

class TipsViewController: UIViewController {
    //@IBOutlet weak var ecoPointsLabel: UILabel!
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        ecoPointsLabel.text = ( "🌿" + String(K.Points.numPoints))
        print("Tips view container was loaded")
        // Do any additional setup after loading the view.
    }
    
    @IBAction func buttonPressed(_ sender: UIButton) {
        print("button to water conservation pressed")
    }
    @IBAction func updatePoints(_ sender: UIButton) {
        K.Points.numPoints=900

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

        
        
// ADDING A DOC TO FIREBASE
//        print("update points method was run")
//        if let currentUser = Auth.auth().currentUser?.email {
//                    db.collection(K.FStore.collectionName).addDocument(data: [
//                        "currentUser" : currentUser,
//                        "numEcoPoints":K.Points.numPoints
//                    ]) { (error) in
//                        if let e = error {
//                            print("There was an issue saving data to firestore, \(e)")
//                        } else {
//                            print("Successfully saved data.")
//                        }
//                    }
//                }
// }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
