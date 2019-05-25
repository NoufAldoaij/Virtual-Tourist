//
//  DataControllers.swift
//  Virtual Tourist
//
//  Created by Nouf Abdullah on 5/22/19.
//  Copyright © 2019 Nouf Abdullah. All rights reserved.
//

import Foundation
import CoreData

class DataControllers {
    
    let persistentContainer: NSPersistentContainer
    
    var viewContext:NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    init(modelName:String) {
        persistentContainer = NSPersistentContainer(name: modelName)
    }
    
    func load(completion: (()-> Void)? = nil) {
        persistentContainer.loadPersistentStores { (storeDescription, error) in
            guard error == nil else {
                fatalError(error!.localizedDescription)
            }
            completion?()
        }
    }
}
