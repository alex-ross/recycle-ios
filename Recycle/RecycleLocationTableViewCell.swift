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
        setupKindName()

        materialGlass.hidden = !hasMaterial("glass")
        materialCardboard.hidden = !hasMaterial("cardboard")
        materialPlastic.hidden = !hasMaterial("plastic")
        materialMagazines.hidden = !hasMaterial("magazines")
        materialMetal.hidden = !hasMaterial("metal")
    }

    func hasMaterial(material: String) -> Bool {
        return recycleLocation.materials.contains(material)
    }

    func setupKindName() {
        switch recycleLocation.kind {
        case "recycle_station":
            kindLabel.text = "Återvinningstation"
        case "recycle_central":
            kindLabel.text = "Återvinningcentral"
        default:
            kindLabel.text = "Okänd typ"
        }
    }
}
