//
//  moneyLogsApp.swift
//  moneyLogs
//
//  Created by ikue uda on 2025/05/17.
//

import SwiftUI

@main
struct moneyLogsApp: App {
    let persistenceController = PersistenceController.shared
    
    init() {
        persistenceController.preloadCategoriesIfNeeded()
    }

    var body: some Scene {
        WindowGroup {
            EntryFormView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
