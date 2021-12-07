import CoreData

class CoreDataStore: BudgeteerStore {
    lazy var container: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "BudgetModel")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    func storeBudget(budget: Budget) {
        let context = container.newBackgroundContext()
        guard let entityDescription = NSEntityDescription.entity(forEntityName: "BudgetEntity", in: context) else {
            return
        }
        let managedBudgetItem = NSManagedObject(entity: entityDescription, insertInto: context)
        
        managedBudgetItem.setValue(budget.balance, forKey: "balance")
        managedBudgetItem.setValue(budget.budgetId, forKey: "budgetId")
        managedBudgetItem.setValue(budget.name, forKey: "name")
        do {
            try context.save()
        } catch {
            return
        }
    }
    
    func updateBudgetBalance(_ budgetId: Int, balance: Double) {
        let context = container.newBackgroundContext()
        let request = NSFetchRequest<NSManagedObject>(entityName: "BudgetEntity")
        request.predicate = NSPredicate(format: "budgetId = %@", argumentArray: [budgetId])
        
        do {
            let managedObjects = try context.fetch(request)
            guard !managedObjects.isEmpty else {
                return
            }
            managedObjects.first?.setValue(balance, forKey: "balance")
            try context.save()
        } catch {
            
        }
    }
    
    func getAllBudgetItems() -> [Budget] {
        let budgetRequest = NSFetchRequest<NSManagedObject>(entityName: "BudgetEntity")
        let budgetContext = container.viewContext
        let transactionRequest = NSFetchRequest<NSManagedObject>(entityName: "TransactionEntity")
        let transactionContext = container.viewContext
        
        do {
            let managedBudgetItems: [NSManagedObject] = try budgetContext.fetch(budgetRequest)
            var budgetItems: [Budget] = managedBudgetItems.compactMap { Budget(managedBudgetItems: $0) }
            let managedTransactionItems: [NSManagedObject] = try transactionContext.fetch(transactionRequest)
            let transactionItems: [Transaction] = managedTransactionItems.compactMap { Transaction(managedTransactionItems: $0) }
            for i in 0..<transactionItems.count {
                for j in 0..<budgetItems.count {
                    if transactionItems[i].budgetId == budgetItems[j].budgetId {
                        if budgetItems[j].transactions == nil {
                            budgetItems[j].transactions = [transactionItems[i]]
                        } else {
                            budgetItems[j].transactions?.append(transactionItems[i])
                        }
                        break
                    }
                }
            }
            return budgetItems
        } catch {
            return []
        }
    }
    
    func storeTransaction(transaction: Transaction) {
        print("Storing Transaction")
        let context = container.newBackgroundContext()
        guard let entityDescription = NSEntityDescription.entity(forEntityName: "TransactionEntity", in: context) else {
            return
        }
        let managedTransactionItem = NSManagedObject(entity: entityDescription, insertInto: context)
        
        managedTransactionItem.setValue(transaction.amount, forKey: "amount")
        managedTransactionItem.setValue(transaction.budgetId, forKey: "budgetId")
        managedTransactionItem.setValue(transaction.description, forKey: "transactionDescription")
        managedTransactionItem.setValue(transaction.transactionId, forKey: "transactionId")
        do {
            try context.save()
        } catch {
            return
        }
    }
    
    func deleteTransaction(_ budgetId: Int, _ transactionId: Int) {
        let context = container.newBackgroundContext()
        let request = NSFetchRequest<NSManagedObject>(entityName: "TransactionEntity")
        let transactionIdPredicate = NSPredicate(format: "transactionId = %@", argumentArray: [transactionId])
        let budgetIdPredicate = NSPredicate(format: "budgetId = %@", argumentArray: [budgetId])
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [budgetIdPredicate, transactionIdPredicate])
        
        do {
            let managedObjects = try context.fetch(request)
            guard let deleteObject = managedObjects.first else {
                return
            }
            print("deleteObject: \(deleteObject)")
            context.delete(deleteObject)
            try context.save()
        } catch {
            return
        }
    }
}

extension Budget {
    init?(managedBudgetItems: NSManagedObject) {
            guard
                let balance = managedBudgetItems.value(forKey: "balance") as? Double,
                let budgetId = managedBudgetItems.value(forKey: "budgetId") as? Int64,
                let name = managedBudgetItems.value(forKey: "name") as? String
            else {
                return nil
            }
            self.balance = balance
            self.budgetId = Int(budgetId)
            self.name = name
    }
}

    extension Transaction {
        init?(managedTransactionItems: NSManagedObject) {
            guard
                let amount = managedTransactionItems.value(forKey: "amount") as? Double,
                let budgetId = managedTransactionItems.value(forKey: "budgetId") as? Int64,
                let description = managedTransactionItems.value(forKey: "transactionDescription") as? String,
                let transactionId = managedTransactionItems.value(forKey: "transactionId") as? Int64
            else {
                return nil
            }
            self.amount = amount
            self.budgetId = Int(budgetId)
            self.description = description
            self.transactionId = Int(transactionId)
        }
    }
