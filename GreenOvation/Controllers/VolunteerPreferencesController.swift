import UIKit

class VolunteerPreferencesController: UIViewController {

    @IBOutlet weak var drawingPaintingButton: UIButton!
    @IBOutlet weak var photographyButton: UIButton!
    
    @IBOutlet weak var animalCareButton: UIButton!
    
    @IBOutlet weak var webDesignButton: UIButton!
    @IBOutlet weak var graphicDesignButton: UIButton!
    
    
    @IBOutlet weak var habitatRestorationButton: UIButton!
    
    @IBOutlet weak var marketResearchButton: UIButton!
    @IBOutlet weak var businessAnalysisButton: UIButton!
    
    
    @IBOutlet weak var engineeringButton: UIButton!
    @IBOutlet weak var roboticsButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        // You can setup initial states here if needed.
    }
    @IBAction func randoButtonTappedDeleteLater(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected

        if sender.isSelected {
            sender.backgroundColor = UIColor(named: "Green4") // Background color when selected
            sender.setTitleColor(UIColor(named: "Green1"), for: .normal) // Text color when selected
        } else {
            sender.backgroundColor = UIColor(named: "Green1") // Background color when not selected
            sender.setTitleColor(UIColor(named: "Green4"), for: .normal) // Text color when not selected
        }
    }
    @IBAction func preferenceButtonTapped(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected

            if sender.isSelected {
                sender.backgroundColor = UIColor(named: "Green4") // Background color when selected
                sender.setTitleColor(UIColor(named: "Green1"), for: .normal) // Text color when selected
                
                print("button color when selected: \(sender.titleColor(for: .normal)?.description ?? "unknown")")

            } else {
                sender.backgroundColor = UIColor(named: "Green1") // Background color when not selected
                sender.setTitleColor(UIColor(named: "Green4"), for: .normal) // Text color when not selected
                print("button color when selected: \(sender.titleColor(for: .normal)?.description ?? "unknown")")

            }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
//        if let button = sender as? UIButton {
            if(segue.identifier=="goToVolunteerOpportunities") {
                let destinationVC = segue.destination as! FindPlaceViewController
                    if(photographyButton.isSelected) { destinationVC.preferencesArray.append("Photography")
                    }
                    if(drawingPaintingButton.isSelected) { destinationVC.preferencesArray.append("Drawing/Painting")
                    }
                    if(animalCareButton.isSelected) { destinationVC.preferencesArray.append("Animal Care")
                    }
                    if(habitatRestorationButton.isSelected) { destinationVC.preferencesArray.append("Habitat Restoration")
                    }
                    if(webDesignButton.isSelected) { destinationVC.preferencesArray.append("Web Design")
                    }
                    if(graphicDesignButton.isSelected) { destinationVC.preferencesArray.append("Graphic Design")
                    }
                    if(marketResearchButton.isSelected) { destinationVC.preferencesArray.append("Market Research")
                    }
                    if(businessAnalysisButton.isSelected) { destinationVC.preferencesArray.append("Business Analysis")
                    }
                    if(engineeringButton.isSelected) { destinationVC.preferencesArray.append("Engineering")
                    }
                    if(roboticsButton.isSelected) { destinationVC.preferencesArray.append("Robotics")
                    }
            }
//        }
    }
    @IBAction func nextPressed(_ sender: UIButton) {
        self.performSegue(withIdentifier: "goToVolunteerOpportunities", sender: self)
    }
    
}
