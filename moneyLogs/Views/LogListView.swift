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

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \LogEntry.date, ascending: false)],
        animation: .default)
    private var entries: FetchedResults<LogEntry>

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter
    }()

    var body: some View {
        NavigationView {
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

                        Text(dateFormatter.string(from: entry.date ?? Date()))
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
            }
        }
    }
}
