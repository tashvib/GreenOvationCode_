import UIKit

class DailyChallengeViewController: UIViewController {
    var linkText: String = ""
    
    @IBOutlet weak var linkTextView: UITextView!
    @IBOutlet weak var dateLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        linkTextView.text = "Tap here to share a pic"
        print(linkTextView.text ?? "")
        linkText = "http://instagram.com" // make sure you include "http://"
        linkTextView.isUserInteractionEnabled = true
        linkTextView.isEditable = false
        linkTextView.isSelectable = true
        linkTextView.isUserInteractionEnabled = true

        makeLinkTextHyperlink()
        let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MMM dd, yyyy" // Customize the date format as per your preference
                
                let currentDate = Date()
                let dateString = dateFormatter.string(from: currentDate)
                
                dateLabel.text = dateString
        // Do any additional setup after loading the view.
    }
    func makeLinkTextHyperlink(){
        let path = linkText
        let text = linkTextView.text ?? ""
        let font = linkTextView.font
        let textColor = linkTextView.textColor
        let alignment = linkTextView.textAlignment
        let attributedString = NSAttributedString.makeHyperlink(for: path, in: text, as: "Tap here to share a pic")
        linkTextView.attributedText = attributedString
        linkTextView.font = font
        linkTextView.textColor = textColor
        linkTextView.textAlignment = alignment

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
