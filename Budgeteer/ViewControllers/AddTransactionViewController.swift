import UIKit

protocol AddTransactionDelegate: AnyObject {
    func addTransaction(_ amountToAdd: Double, _ description: String)
}

class AddTransactionViewController: UIViewController {
    
    @IBOutlet weak var amountToAddLabelOutlet: UILabel!
    @IBOutlet weak var amountToAddOutlet: UITextField!
    @IBOutlet weak var descriptionOutlet: UITextField!
    @IBOutlet weak var addButtonOutlet: UIButton!
    
    weak var delegate: AddTransactionDelegate?
    
    var addPositiveFunds: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if addPositiveFunds {
            navigationItem.title = "Add Funds"
            amountToAddLabelOutlet.text = "Amount to Add"
            addButtonOutlet.setTitle("Add Funds", for: .normal)
        } else {
            navigationItem.title = "Add Expense"
            amountToAddLabelOutlet.text = "Amount to Add"
            addButtonOutlet.setTitle("Add Expense", for: .normal)
        }
    }
    
    @IBAction func addTransactionButtonAction(_ sender: Any) {
        guard
            let unwrappedAmountToAdd = amountToAddOutlet.text,
            var doubleAmountToAdd: Double = Double(unwrappedAmountToAdd),
            let unwrappedDescription = descriptionOutlet.text
        else {
            return
        }
        
        if addPositiveFunds == false {
            doubleAmountToAdd = doubleAmountToAdd * -1
        }
        _ = navigationController?.popViewController(animated: true)
        delegate?.addTransaction(doubleAmountToAdd, unwrappedDescription)
    }
}
