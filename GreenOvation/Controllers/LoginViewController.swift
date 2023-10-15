import UIKit
import Firebase

class LoginViewController: UIViewController {

    @IBOutlet weak var emailTextfield: UITextField!
    @IBOutlet weak var passwordTextfield: UITextField!
    

    @IBAction func loginPressed(_ sender: UIButton) {
        print("loginPressed")
        if let email = emailTextfield.text, let password = passwordTextfield.text {
            Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
                if let e = error {
                    print(e.localizedDescription)
                } else {
                    //Navigate to leaderboardviewcontrolelr
                    DispatchQueue.main.async {
                        self?.performSegue(withIdentifier: "LoginToStart", sender: self)
                    }
                }
              
            }
        }
    }
    
}
