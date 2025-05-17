//
//  EntryFormView.swift
//  moneyLogs
//
//  Created by ikue uda on 2025/05/17.
//

import SwiftUI
import CoreData

struct EntryFormView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @State private var date = Date()
    @State private var selectedCategory: LogCategory?
    @State private var amount = ""
    @State private var memo = ""

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \LogCategory.name, ascending: true)],
        animation: .default)
    private var categories: FetchedResults<LogCategory>

    var body: some View {
        NavigationView {
            Form {
                DatePicker("Date", selection: $date, displayedComponents: .date)

                Picker("Category", selection: $selectedCategory) {
                    ForEach(categories, id: \.self) { category in
                        Text(category.name ?? "").tag(category as LogCategory?)
                    }
                }

                TextField("Amount", text: $amount)
                    .keyboardType(.decimalPad)

                TextField("Memo (optional)", text: $memo)

                Button("Save") {
                    saveEntry()
                }
                .disabled(!canSave)
            }
            .onAppear {
                if selectedCategory == nil && !categories.isEmpty {
                    selectedCategory = categories.first
                }
            }
        }
    }

    private var canSave: Bool {
        selectedCategory != nil && Decimal(string: amount) != nil
    }

    private func saveEntry() {
        guard let selectedCategory = selectedCategory,
              let amountValue = Decimal(string: amount) else { return }

        let entry = LogEntry(context: viewContext)
        entry.date = date
        entry.amount = amountValue as NSDecimalNumber
        entry.memo = memo
        entry.category = selectedCategory.name

        do {
            try viewContext.save()
            print("Entry saved")
            resetForm()
        } catch {
            print("Failed to save entry: \(error)")
        }
    }

    private func resetForm() {
        date = Date()
        selectedCategory = categories.first
        amount = ""
        memo = ""
    }
}
