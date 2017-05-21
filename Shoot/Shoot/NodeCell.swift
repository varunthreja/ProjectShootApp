
//

import UIKit
//it represent each score view table view cell
class NodeCell: UITableViewCell {

    //parameter
    @IBOutlet var number: UILabel!
    @IBOutlet var score: UILabel!
    @IBOutlet var time: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
