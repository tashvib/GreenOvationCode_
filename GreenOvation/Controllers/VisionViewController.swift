import UIKit
import CoreML
import Vision
import Firebase

class VisionViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var descriptionText: UITextView!
    @IBOutlet weak var titleText: UITextView!
    @IBOutlet weak var itemidentification: UILabel!
    
    @IBOutlet weak var recycleableOutlet: UIButton!
    @IBOutlet weak var organicWasteOutlet: UIButton!
    @IBOutlet weak var eWasteOutlet: UIButton!
    @IBOutlet weak var hazardousWasteOutlet: UIButton!
    @IBOutlet weak var finish: UIButton?
    //@IBOutlet weak var ecoPointsLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    let imagePicker = UIImagePickerController()
    var itemIdentified = ""
    var numCorrect = 0
    var numAnswered = 0
    var correctOrNotVar: Bool = false
    @IBOutlet weak var progressBar: UIProgressView!
    
    func updateProgressBar(){
        let progressFraction = Double(numAnswered) / Double(5)
        
        progressBar.progressTintColor = UIColor(named: "Green3")

        progressBar.progress = Float(progressFraction)
    }
    
    @IBAction func eWastePressed(_ sender: Any) {
        
        imageView.image = nil
        correctOrNot(userGuess: "ewaste", userItem: itemIdentified)
        //update points
        if(numAnswered==5){
            finish!.isEnabled = true
        }
        recycleableOutlet.isEnabled = false
        hazardousWasteOutlet.isEnabled = false
        organicWasteOutlet.isEnabled = false
    }
    
    @IBAction func organicPressed(_ sender: UIButton) {
        
        imageView.image = nil
    correctOrNot(userGuess: "organic waste", userItem: itemIdentified)
        if(numAnswered==5){
            finish!.isEnabled = true
        }
        recycleableOutlet.isEnabled = false
        hazardousWasteOutlet.isEnabled = false
        eWasteOutlet.isEnabled = false
    }
    
    @IBAction func recyclePressed(_ sender: UIButton) {
        
        imageView.image = nil
    correctOrNot(userGuess: "recyclable", userItem: itemIdentified)
        if(numAnswered==5){
            finish!.isEnabled = true
        }
        eWasteOutlet.isEnabled = false
        hazardousWasteOutlet.isEnabled = false
        organicWasteOutlet.isEnabled = false
    }
    
    
    @IBAction func hazardousPressed(_ sender: UIButton) {
        
        imageView.image = nil
        correctOrNot(userGuess: "hazardous waste", userItem: itemIdentified)
        print("hazardousPressed")
        if(numAnswered==5){
            finish!.isEnabled = true
        }
        recycleableOutlet.isEnabled = false
        eWasteOutlet.isEnabled = false
        organicWasteOutlet.isEnabled = false
    }
    func correctOrNot(userGuess: String, userItem: String) {
        print("inside correctOrNot")
        
        let db = Firestore.firestore()
        let wasteManagementCollection = db.collection("wastemanagement")
        
        // Query the wasteManagement collection for documents with matching item
        wasteManagementCollection.whereField("item", isEqualTo: userItem).getDocuments { [weak self] (querySnapshot, error) in
            guard let self = self else { return }
            
            if let error = error {
                print("Error getting documents: \(error)")
                // Handle the error, e.g., show an error message to the user
            } else {
                // Check if any matching documents were found
                if let documents = querySnapshot?.documents, let firstDocument = documents.first {
                    // Extract the description and typeDisposalMethod from the document
                    let data = firstDocument.data()
                    let description = data["description"] as? String
                    var title = data["title"] as? String
                    let item = data["item"] as? String
                    let typeDisposalMethod = data["typeDisposalMethod"] as? String
                    
                    
                    self.correctOrNotVar = (typeDisposalMethod == userGuess)
                    self.descriptionText.backgroundColor = self.correctOrNotVar ? UIColor(named: "Green2") : .red
                    self.titleText.backgroundColor = self.correctOrNotVar ? UIColor(named: "Green2") : .red
                    self.descriptionText.text = description ?? ""
                    title = title ?? ""
                    let titleAddOn = self.correctOrNotVar ? "Correct!" : "Incorect."
                    numAnswered+=1
                    updateProgressBar()
                    if(numAnswered==5){
                        finish!.isEnabled = true
                    }
                    title = "\(titleAddOn) \(String(describing: title ?? ""))"
                    self.titleText.text = title ?? ""
                    if(self.correctOrNotVar) {
                        numCorrect+=1
                    }
                } else {
                    // No matching document found
                    self.descriptionText.text = "No description found"
                }
            }
        }
    }
    
    @IBAction func finishPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "GoToFinished", sender: self)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        self.navigationItem.title = "Back"
        if(segue.identifier == "GoToFinished") {
            let destinationVC = segue.destination as! FinishedVisionViewController
            destinationVC.numCorrect = numCorrect
        }
    }
    
    
    override func viewDidLoad() {
        
        
        super.viewDidLoad()
        if let finishButton = finish {
                finishButton.isEnabled = false
            } else {
                print("finish button outlet not connected")
            }
        descriptionText?.backgroundColor = .clear
        descriptionText?.text = ""
        titleText?.backgroundColor = .clear
        titleText?.text = ""
        numCorrect=0
        
//        ecoPointsLabel.text = ( "🌿" + String(K.Points.numPoints))
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = false

        // Do any additional setup after loading the view.
    }
    

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let userPickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
            imageView.image = userPickedImage

            guard let ciimage = CIImage(image: userPickedImage) else {
                fatalError("Could not convert to CIImage")
            }
            detect(image: ciimage)
        }
        imagePicker.dismiss(animated: true, completion: nil)
        
        recycleableOutlet.isEnabled = true
        hazardousWasteOutlet.isEnabled = true
        organicWasteOutlet.isEnabled = true
        eWasteOutlet.isEnabled = true
    }

    func detect(image: CIImage){

        guard let model = try? VNCoreMLModel(for: Inceptionv3().model) else {
            fatalError("Loading CoreML Model Failed.")
        }

        let request = VNCoreMLRequest(model: model) { request, error in
            guard let results = request.results as? [VNClassificationObservation] else {
                fatalError("MOdel failed to process image")
            }

//            if let firstResult = results.first {
//                        let highestConfidenceResult = results.max(by: { $0.confidence < $1.confidence })
//                        if let highestConfidenceResult = highestConfidenceResult {
//                            self.navigationItem.title = highestConfidenceResult.identifier
//                        } else {
//                            self.navigationItem.title = "No results found"
//                        }
//                    } else {
//                        self.navigationItem.title = "No results found"
//                    }

            if let firstResult = results.first {
                var resultString = firstResult.identifier // Use a mutable variable to hold the result string
                if let commaRange = resultString.range(of: ",") {
                    let substring = resultString[..<commaRange.lowerBound]
                    resultString = String(substring) // Update the resultString with the modified substring
                }
                print("resultString: \(resultString)")
                self.navigationItem.title = resultString
                self.itemIdentified = resultString
            }


            print("HELLOGOODBYE\(results)")
        }
        let handler = VNImageRequestHandler(ciImage: image)

        do{
            try! handler.perform([request])
        }
        catch{
            print(error)
        }
    }
        
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let userPickedImage = info[UIImagePickerController.InfoKey.originalImage.rawValue] as? UIImage {
            imageView.image = userPickedImage
        }
        imagePicker.dismiss(animated: true, completion: nil)
    }
    @IBAction func cameraTapped(_ sender: UIButton) {
        print("cameraTapped")
        descriptionText?.backgroundColor = .clear
        descriptionText?.text = ""
        titleText?.backgroundColor = .clear
        titleText?.text = ""
        if(numAnswered==5){
            if let cameraButtonButton = cameraButton {
                cameraButtonButton.isEnabled = false
                } else {
                    print("finish button outlet not connected")
                }
            
        }
        present(imagePicker, animated: true, completion: nil)
    }
}


//present(imagePicker, animated: true, completion: nil)
