//
//  LogListView.swift
//  moneyLogs
//
//  Created by ikue uda on 2025/05/17.
//

import SwiftUI
import CoreData

struct LogListView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @State private var currentMonth = Date()
    @State private var entries: [LogEntry] = []

    private let calendar = Calendar.current

    private let entryDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter
    }()

    private var monthLabel: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年M月"
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: currentMonth)
    }

    var body: some View {
        NavigationView {
            VStack {
                // ナビゲーションバー
                HStack {
                    Button("＜") {
                        moveMonth(by: -1)
                    }
                    Spacer()
                    Text(monthLabel)
                        .font(.headline)
                    Spacer()
                    Button("＞") {
                        moveMonth(by: 1)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 10)

                List {
                    ForEach(entries) { entry in
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Text(entry.category ?? "（unknown）")
                                    .font(.headline)
                                Spacer()
                                Text("¥\(entry.amount?.intValue ?? 0)")
                                    .font(.headline)
                            }

                            Text(entryDateFormatter.string(from: entry.date ?? Date()))
                                .font(.subheadline)
                                .foregroundColor(.gray)

                            if let memo = entry.memo, !memo.isEmpty {
                                Text(memo)
                                    .font(.footnote)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.vertical, 6)
                    }
                    .onDelete(perform: deleteEntry)
                }
            }
            .onAppear {
                fetchEntries()
            }
            .onChange(of: currentMonth, initial: false) {
                fetchEntries()
            }
        }
    }

    // 表示月移動
    private func moveMonth(by value: Int) {
        if let newMonth = calendar.date(byAdding: .month, value: value, to: currentMonth) {
            currentMonth = newMonth
        }
    }

    // 指定月のログだけ取得
    private func fetchEntries() {
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: currentMonth))!
        let endOfMonth = calendar.date(byAdding: DateComponents(month: 1, second: -1), to: startOfMonth)!

        let request: NSFetchRequest<LogEntry> = LogEntry.fetchRequest()
        request.predicate = NSPredicate(format: "date >= %@ AND date <= %@", startOfMonth as NSDate, endOfMonth as NSDate)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \LogEntry.date, ascending: false)]

        do {
            entries = try viewContext.fetch(request)
        } catch {
            print("Fetch failed: \(error)")
            entries = []
        }
    }

    private func deleteEntry(at offsets: IndexSet) {
        for index in offsets {
            let entry = entries[index]
            viewContext.delete(entry)
        }

        do {
            try viewContext.save()
            // 表示を更新
            fetchEntries()
        } catch {
            print("Failed to delete: \(error)")
        }
    }

}
