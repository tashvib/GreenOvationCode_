import UIKit
import NaturalLanguage

struct ArticleResponse: Codable {
    let articles: [Article]
}
struct Source: Codable {
    let id: String?
    let name: String?
}

struct Article: Codable {
    let source: Source
    let title: String
    let description: String?
    let url: String
}

class SentimentViewController: UIViewController, UITextFieldDelegate{
    var articleHeadlines: [String] = []
    var articleDescriptions: [String] = []
    var articleUrls: [String] = []
    var articleSourceNames: [String] = []
    @IBOutlet weak var tableViewForArticles: UITableView!
    @IBOutlet weak var searchTextField: UITextField!
    private lazy var sentimentClassifier: NLModel? = {
        let model = try? NLModel(mlModel: SentimentClassifier().model)
        return model
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        searchTextField.delegate = self
        tableViewForArticles?.delegate = self
        tableViewForArticles?.dataSource = self
        tableViewForArticles?.rowHeight = 95
    }

    func fetchData(searchQuery: String){
        let searchQuery_ = searchQuery.replacingOccurrences(of: " ", with: "%20")
        let newsArticleURL = "https://newsapi.org/v2/everything?q=\(searchQuery_)&from=2023-07-18&sortBy=popularity&apiKey=51f22cc66a4b400f8accaa447b502823"
        guard let url = URL(string: newsArticleURL) else {
            print("Invalid URL")
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                print("Error: \(error)")
            } else if let data = data {
                do {
                    let decoder = JSONDecoder()
                    let responseObject = try decoder.decode(ArticleResponse.self, from: data)
                    self.articleHeadlines = responseObject.articles.prefix(10).map { (article: Article) -> String in
                        return article.title
                    }
                    self.articleDescriptions = responseObject.articles.prefix(10).map { (article: Article) -> String in
                        return article.description ?? "Whoops! Looks like we can't provide a description for this article, click the link to find out more"
                    }
                    self.articleUrls = responseObject.articles.prefix(10).map { (article: Article) -> String in
                        return article.url
                    }
                    self.articleSourceNames = responseObject.articles.prefix(10).map { (article: Article) -> String in
                        return article.source.name ?? "No source name"
                    }
                    DispatchQueue.main.async {
                        self.tableViewForArticles.reloadData()
                    }
                } catch {
                    print("Error decoding JSON: \(error)")
                }
            }
        }
        task.resume()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "GoToArticleDescription" {
            // Check if the segue identifier matches the one you've set in the storyboard
            print("hello again")
            if let button = sender as? UIButton {
                // Access the button tag and pass it to the destination view controller
                let buttonTag = button.tag
                print("in prepare: \(buttonTag)")
                

                // Access the destination view controller
                if let destinationVC = segue.destination as? ArticleInfoViewController {
                    destinationVC.buttonTag = buttonTag
                    destinationVC.linkText = articleUrls[buttonTag]
                    destinationVC.descriptionText = articleDescriptions[buttonTag]
                    destinationVC.titleText = articleHeadlines[buttonTag]
                    destinationVC.sourceNameText = articleSourceNames[buttonTag]
                    if let sentimentLabel = sentimentClassifier?.predictedLabel(for: articleHeadlines[buttonTag]) {
                        switch sentimentLabel {
                            case "positive":
                                destinationVC.negPosBiasedText = "Positive"
                            case "negative":
                                destinationVC.negPosBiasedText = "Negative"
                            default:
                                destinationVC.negPosBiasedText = "Neutral"
                        }
                    }

                }
            }
        }
    }
    
    @IBAction func searchButtonPressed(_ sender: Any) {
        searchTextField.endEditing(true)
        print(searchTextField.text ?? "")
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        print(searchTextField.text ?? "")
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let searchQuery = searchTextField.text {
            fetchData(searchQuery: searchQuery)
        }
        searchTextField.text = ""
    }
}

extension SentimentViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return articleHeadlines.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell2", for: indexPath) as! TableViewCellForArticles
        if let label = sentimentClassifier?.predictedLabel(for: articleHeadlines[indexPath.row]) {
            switch label {
            case "positive":
                cell.negPosImg?.image = UIImage(systemName: "plus.square.fill")
            case "negative":
                cell.negPosImg?.image = UIImage(systemName: "minus.square.fill")
            default:
                cell.negPosImg?.image = UIImage(systemName: "circle.square.fill")
            }
        }
        cell.headlineLabel?.text = articleHeadlines[indexPath.row]
        cell.arrowButton.tag = indexPath.row
        print("cell.arrowButton.tag: \(cell.arrowButton.tag)")
        return cell
    }
}
