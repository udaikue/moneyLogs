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
            TabView {
                EntryFormView()
                    .tabItem {
                        Label("Input", systemImage: "plus.circle")
                    }

                LogListView()
                    .tabItem {
                        Label("History", systemImage: "list.bullet")
                    }
            }
            .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
