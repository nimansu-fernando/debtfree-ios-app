//
//  Persistence.swift
//  DebtFree
//
//  Created by COBSCCOMPY4231P-006 on 2024-10-26.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

//    static var preview: PersistenceController = {
//        let result = PersistenceController(inMemory: true)
//        let viewContext = result.container.viewContext
//        for _ in 0..<10 {
//            let newItem = Item(context: viewContext)
//            newItem.timestamp = Date()
//        }
//        do {
//            try viewContext.save()
//        } catch {
//            // Replace this implementation with code to handle the error appropriately.
//            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
//            let nsError = error as NSError
//            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
//        }
//        return result
//    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "DebtFree")
        
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        
        // Add configuration for concurrent loading
        container.persistentStoreDescriptions.first?.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
        
        container.loadPersistentStores { description, error in
            if let error = error as NSError? {
                print("Error loading persistent stores: \(error), \(error.userInfo)")
                // Instead of fatal error, log the error and handle gracefully
                #if DEBUG
                fatalError("Unresolved error \(error), \(error.userInfo)")
                #else
                print("Serious error loading store: \(error)")
                #endif
            }
        }
        
        // Configure the view context
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        
        // Add error handling
        container.viewContext.shouldDeleteInaccessibleFaults = true
    }
    
    // Add function to setup initial context for user
    func setupInitialContext(for userId: String) {
        let context = container.viewContext
        
        // Create a background context for setup
        container.performBackgroundTask { backgroundContext in
            // Setup any initial data if needed
            // For example, you might want to create default categories or settings
            
            do {
                try backgroundContext.save()
                
                // Merge changes into the main context
                context.perform {
                    context.mergeChanges(fromContextDidSave: Notification(name: .NSManagedObjectContextDidSave))
                }
            } catch {
                print("Error setting up initial context: \(error)")
            }
        }
    }
}
