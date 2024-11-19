//
//  Persistence.swift
//  DebtFree
//
//  Created by COBSCCOMPY4231P-006 on 2024-10-26.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

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
