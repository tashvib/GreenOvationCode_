

import UIKit

class TableViewCellForArticles: UITableViewCell {
    @IBOutlet weak var negPosImg: UIImageView!
    @IBOutlet weak var arrowButton: UIButton!
    @IBOutlet weak var headlineLabel: UITextView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
