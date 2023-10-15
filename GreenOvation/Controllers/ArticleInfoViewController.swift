import UIKit

class ArticleInfoViewController: UIViewController {
    @IBOutlet weak var linkTextView: UITextView!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var titleTextView: UITextView!
    @IBOutlet weak var sourceNameTextView: UITextView!
    @IBOutlet weak var negPosBiasedTextView: UITextView!
    var descriptionText: String = ""
    var titleText: String = ""
    var linkText: String = ""
    var sourceNameText: String = ""
    var buttonTag: Int = 0
    var negPosBiasedText: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        linkTextView.isUserInteractionEnabled = true

        makeLinkTextHyperlink()
        
        titleTextView.text = titleText
        descriptionTextView.text = descriptionText
        sourceNameTextView.text = sourceNameText
        if(negPosBiasedText=="Positive"){
            negPosBiasedText = "This article is positively biased towards its subject"
            negPosBiasedTextView.backgroundColor = UIColor(named: "greeeeeen") ?? UIColor.red
        }
        else if(negPosBiasedText=="Negative"){
            negPosBiasedText = "This article is negatively biased towards its subject"
            negPosBiasedTextView.backgroundColor = UIColor(named: "lightred") ?? UIColor.red
            
        }
        else {
            negPosBiasedText = "This article is neutral towards its subject"
        }
        negPosBiasedTextView.text = negPosBiasedText
        
        // Do any additional setup after loading the view.
    }
    func makeLinkTextHyperlink(){
        let path = linkText
        let text = linkTextView.text ?? ""
        let font = linkTextView.font
        let textColor = linkTextView.textColor
        let alignment = linkTextView.textAlignment
        let attributedString = NSAttributedString.makeHyperlink(for: path, in: text, as: "Navigate to Article")
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
