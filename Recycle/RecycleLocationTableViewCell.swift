import UIKit

class RecycleLocationTableViewCell: UITableViewCell {
    var recycleLocation: RecycleLocation! {
        didSet {
            setupView()
        }
    }
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var kindLabel: UILabel!

    @IBOutlet weak var materialGlass: UIImageView!
    @IBOutlet weak var materialCardboard: UIImageView!
    @IBOutlet weak var materialPlastic: UIImageView!
    @IBOutlet weak var materialMagazines: UIImageView!
    @IBOutlet weak var materialMetal: UIImageView!

    func setupView() {
        nameLabel.text = recycleLocation.name
        kindLabel.text = recycleLocation.localizedKind

        materialGlass.isHidden = !hasMaterial("glass")
        materialCardboard.isHidden = !hasMaterial("cardboard")
        materialPlastic.isHidden = !hasMaterial("plastic")
        materialMagazines.isHidden = !hasMaterial("magazines")
        materialMetal.isHidden = !hasMaterial("metal")
    }

    func hasMaterial(_ material: String) -> Bool {
        return recycleLocation.materials.contains(material)
    }
}
