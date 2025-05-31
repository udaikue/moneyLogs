//
//  EditableEntryFormView.swift
//  moneyLogs
//
//  Created by ikue uda on 2025/05/31.
//

import SwiftUI
import CoreData

struct EditableEntryFormView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss

    var entryToEdit: LogEntry? = nil // nilなら新規

    @State private var date = Date()
    @State private var selectedCategory: LogCategory?
    @State private var amount = ""
    @State private var memo = ""

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \LogCategory.name, ascending: true)],
        animation: .default)
    private var categories: FetchedResults<LogCategory>

    var body: some View {
        VStack {
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
            }

            Button("Save") {
                saveEntry()
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(canSave ? Color.blue : Color.gray)
            .foregroundColor(.white)
            .cornerRadius(8)
            .padding(.horizontal)
            .disabled(!canSave)
        }
        .onAppear {
            if let entry = entryToEdit {
                // 編集用に初期値をセット
                date = entry.date ?? Date()
                amount = entry.amount?.stringValue ?? ""
                memo = entry.memo ?? ""
                selectedCategory = categories.first(where: { $0.name == entry.category })
            } else {
                selectedCategory = categories.first
            }
        }
    }

    private var canSave: Bool {
        selectedCategory != nil && Decimal(string: amount) != nil
    }

    private func saveEntry() {
        let entry = entryToEdit ?? LogEntry(context: viewContext)
        entry.date = date
        entry.category = selectedCategory?.name
        entry.memo = memo
        if let amountDecimal = Decimal(string: amount) {
            entry.amount = amountDecimal as NSDecimalNumber
        }

        do {
            try viewContext.save()
            print("Saved entry")
            dismiss()
        } catch {
            print("Failed to save entry: \(error)")
        }
    }
}
