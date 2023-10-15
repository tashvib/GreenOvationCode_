import UIKit
import Firebase

class DescriptionViewController: UIViewController {
    let db = Firestore.firestore()
    @IBOutlet weak var descriptionTextTitle: UITextView!
    @IBOutlet weak var descriptionText: UITextView!
    var descriptionTextTitleText = ""
    var buttonTag: Int = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        adjustUITextViewHeight(arg: descriptionText)
        descriptionText.setContentCompressionResistancePriority(.required, for: .horizontal)
        print("buttonID: \(buttonTag)")
        updateDescriptionText()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func volunteerPressed(_ sender: Any){
        K.Points.numPoints += 300
        updatePoints()
        self.performSegue(withIdentifier: "GoToConfirmation", sender: UIButton())
    }
    
    func updatePoints(){

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
    func adjustUITextViewHeight(arg : UITextView) {
        arg.translatesAutoresizingMaskIntoConstraints = true
        arg.sizeToFit()
        arg.isScrollEnabled = false
    }
    func updateDescriptionText() {
        print(descriptionTextTitle.text ?? "")
        let query = db.collection("volunteeropportunities").whereField("name", isEqualTo: descriptionTextTitleText ?? "")
            
            query.getDocuments { (querySnapshot, error) in
                
                if let error = error {
                    print("Error getting documents: \(error)")
                    return
                }
                
                guard let documents = querySnapshot?.documents else {
                    print("No matching documents")
                    return
                }
//                print("Number of documents: \(documents.count)")
//
                print("rightbefore")
//                for document in documents {
//                    let id = document.data()["id"] as? Int ?? 0
//                    print("Document id: \(id)")
//                }
                if documents.count == 1 {
                    let document = documents[0]
                    let description = document.data()["description"] as? String
                    
                    let name = document.data()["name"] as? String
                    
                    self.descriptionText.text = (description)
                    self.descriptionTextTitle.text = name
                } else {
                    print("Multiple matching documents found")
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
