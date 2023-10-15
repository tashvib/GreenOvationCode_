
import UIKit

class TableViewCellForEvents: UITableViewCell {

    @IBOutlet weak var arrowButton: UIButton!
    @IBOutlet weak var organization: UILabel!
    @IBOutlet weak var nameOfEvent: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
