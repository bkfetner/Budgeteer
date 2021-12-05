import UIKit

protocol DeckCellProtocol: AnyObject {
    func budgetSelected(_ budgetSelected: DeckCell, deckButtonAction budgetId: Int)
}

class DeckCell: UITableViewCell {

    @IBOutlet weak var budgetName: UILabel!
    @IBOutlet weak var budgetAmount: UILabel!
    
    @IBOutlet weak var buttonText: UIButton!
    
    var cellBudgetId:Int?
    
    weak var delegate: DeckCellProtocol?
    
    @IBAction func deckButtonAction(_ sender: UIButton) {
        if let cellBudgetId = cellBudgetId {
            self.delegate?.budgetSelected(self, deckButtonAction: cellBudgetId)
        }
    }
    
    func updateDeck(with updateBudgetId: Int, and updateBudgetName: String, and updateBudgetAmount: Double) {
        self.budgetName.text = "\(updateBudgetName)"
        if updateBudgetAmount < 0 {
            self.budgetAmount.text = "- $" + String(format: "%.2f", fabs(updateBudgetAmount))
        } else {
            self.budgetAmount.text = "$" + String(format: "%.2f", updateBudgetAmount)
        }
        self.cellBudgetId = updateBudgetId
    }
    
    override func prepareForReuse() {
        budgetName.text = ""
        budgetAmount.text = ""
    }
}
