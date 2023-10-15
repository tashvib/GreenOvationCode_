import UIKit
import Firebase

class RegisterViewController: UIViewController {
    let db = Firestore.firestore()
    @IBOutlet weak var emailTextfield: UITextField!
    @IBOutlet weak var passwordTextfield: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    
    @IBAction func registerPressed(_ sender: UIButton) {
        K.userInfo.email = emailTextfield.text ?? ""
        K.userInfo.password = passwordTextfield.text ?? ""
        K.userInfo.username = usernameTextField.text ?? ""
        if let email = emailTextfield.text, let password = passwordTextfield.text {
            if let currentUser = Auth.auth().currentUser {
                do {
                    try Auth.auth().signOut()
                    print("User logged out successfully")
                } catch {
                    print("Error signing out: \(error.localizedDescription)")
                    return
                }
            }
            
            Auth.auth().createUser(withEmail: email, password: password) { [weak self] authResult, error in
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
                
                // User registered successfully
                
                Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
                    if let error = error {
                        print(error.localizedDescription)
                        return
                    }
                    
                    // User logged in successfully
                    print("User has been logged in")
                    
                    // Set up the user's eco points in Firestore
                    if let currentUser = Auth.auth().currentUser?.email {
                        self?.db.collection(K.FStore.collectionName).addDocument(data: [
                            "currentUser" : currentUser,
                            "numEcoPoints":K.Points.numPoints,
                            "username": K.userInfo.username
                        ]) { error in
                            if let error = error {
                                print("There was an issue saving data to Firestore: \(error)")
                            } else {
                                print("Successfully saved data.")
                            }
                        }
                    }
                    
                    // Navigate to leaderboard view controller
                    self?.performSegue(withIdentifier: "RegisterToStart", sender: self)
                }
            }
        }
    }

    
}
