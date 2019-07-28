
# Intro: 
DataWrapper is a Kit for convinience working with CoreData framework of iOS, it helps to simplify common/boilerplates code when working with CoreData by just a few simple line of code, make program more readable and easy to access feature of CoreData without writing a lot of code.

# Feature:

- Create default or custom Core Data stack (or more stacks) easily accessible from everywhere
- Covered with inline docs
- Helping to build NSPredicate 
- Resuable class
    
# Usage: 
 
###Create a core data stack:
 
- With @iOS9 and earlier, to get a stack of coredata you just have to create an instance of CoreDataStack class and pass in the name of the model:
  
```swift
    var coreDataStack= CoreDataStack(modelName: "Notes")
    // "Notes" is the name of the model
    coreDataStack.saveChanges()
```

to access to the ManagedObjectContext you have just created, call: coreDataStack.mainManagedObjectContext
to save pending changes to persistent store,  call coreDataStack.saveChanges() and all the work will be done in the background with a completion handler back to inform fail/success
    
- With @iOS10 and later support PersistentContainer, to create and load model to persistent container:
        
```swift
        var persistentContainer: NSPersistentContainner?
        coreDataStack.loadPersistentContainer(modelName: "Notes") { (persistentContainner, error)
            guard let error == nil else {
                //...
            }
            self.persistentContainer = persistentContainner
        }
```
this function will return a handler with a persistentContainer loaded with the model matched the modelName passed in. 
notice: the work of loading model is done in background.
    
    
###Reusable FetchedResultsTableViewController:

CoreData framework support to present data in TableView always in sync with the data changed in context by using FetchedResultsController class. But when using this class we need to implement all the detail of its delegate so that the TableView can load data properly. With FetchedResultsTableViewController, we just need to let our TableViewController inherit this this class and do not need to care about the delegate things anymore, it make our TableViewController less overloaded by code and easy to read. If we have many TableViews in our app, it can be very helpful.
    
``` swift
    
    SomeTableViewController: FetchedResultsTableViewController {
        
        private lazy var fetchedResultsController: NSFetchedResultsController<Type> = {
            ...
        }
        fetchedResultsController.delegate = self
        
        // do all of your stuff here and don't need to care about the implementation of FetchedResultsController's delegates, as long as you inherit FetchedResultsTableViewController, the data always be in sync.
    
    }
```
    
    
    

 
 



