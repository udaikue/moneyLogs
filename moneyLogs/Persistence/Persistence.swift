//
//  Persistence.swift
//  moneyLogs
//
//  Created by ikue uda on 2025/05/17.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "moneyLogs")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}

extension PersistenceController {
    func preloadCategoriesIfNeeded() {
        let context = container.viewContext
        let fetchRequest = NSFetchRequest<LogCategory>(entityName: "LogCategory")
        fetchRequest.fetchLimit = 1

        do {
            let count = try context.count(for: fetchRequest)
            if count == 0 {
                let defaultCategories = [
                    ("食費", "#FF6B6B"),
                    ("日用品", "#FFA07A"),
                    ("本・雑誌", "#FFD700"),
                    ("美容", "#DA70D6"),
                    ("交際費", "#FF8C00"),
                    ("光熱費", "#20B2AA"),
                    ("衣料", "#4682B4"),
                    ("雑貨", "#6A5ACD"),
                    ("娯楽", "#FF1493"),
                    ("ひとり外食", "#CD5C5C"),
                    ("通信費", "#00CED1"),
                    ("特別費", "#A0522D"),
                    ("医療費", "#8A2BE2"),
                    ("旅費", "#3CB371"),
                    ("家賃", "#2F4F4F")
                ]

                for (name, color) in defaultCategories {
                    let category = LogCategory(context: context)
                    category.name = name
                    category.color = color
                }
                try context.save()
                print("Default categories have been registered.")
            }
        } catch {
            print("Failed to register default categories: \(error)")
        }
    }
}

