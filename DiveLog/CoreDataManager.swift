//
//  CoreDataManager.swift
//  DiveLog
//
//  Created by Michael Whinfrey on 5/13/19.
//  Copyright © 2019 Michael Whinfrey. All rights reserved.
//

import Foundation
import CoreData

public class CoreDataManager {
    
    // MARK: - Properties
    
    private let modelName: String
    
    // MARK: - Initialization
    
    public init(modelName: String)
        { self.modelName = modelName }  // Set Model Name
        
    // MARK: - Core Data Stack
    
    private lazy var managedObjectModel: NSManagedObjectModel = {
        // Fetch Model URL
        guard let modelURL = Bundle.main.url(forResource: self.modelName, withExtension: "momd") else
            { fatalError("Unable to Find Data Model") }
        
        // Initialize Managed Object Model
        guard let managedObjectModel = NSManagedObjectModel(contentsOf: modelURL) else
            { fatalError("Unable to Load Data Model") }
        
        return managedObjectModel
    }()
    
    
    private lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // Initialize Persistent Store Coordinator
        let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        
        // Helpers
        let fileManager = FileManager.default
        let storeName = "\(self.modelName).sqlite"
        
        // URL Documents Directory
        let documentsDirectoryURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        
        // URL Persistent Store
        let persistentStoreURL = documentsDirectoryURL.appendingPathComponent(storeName)
        
        do {
            let options = [
                NSMigratePersistentStoresAutomaticallyOption : true,
                NSInferMappingModelAutomaticallyOption : true
            ]
            
            // Add Persistent Store
            try persistentStoreCoordinator.addPersistentStore(ofType: NSSQLiteStoreType,
                                                              configurationName: nil,
                                                              at: persistentStoreURL,
                                                              options: options)
            
        } catch
            { fatalError("Unable to Add Persistent Store") }
        
        return persistentStoreCoordinator
    }()
    
    public private(set) lazy var managedObjectContext: NSManagedObjectContext = {
        // Initialize Managed Object Context
        let managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        
        // Configure Managed Object Context
        managedObjectContext.persistentStoreCoordinator = self.persistentStoreCoordinator
        
        return managedObjectContext
    }()
}
