#!/usr/bin/env swift

import Foundation

let fm = FileManager.default
let trashURL = fm.homeDirectoryForCurrentUser.appendingPathComponent(".Trash")

let items = try fm.contentsOfDirectory(
    at: trashURL,
    includingPropertiesForKeys: [.addedToDirectoryDateKey],
    options: []
)

let df = DateFormatter()
df.dateFormat = "yyyy-MM-dd HH:mm:ss"

var results: [(Date, String)] = []
for item in items {
    let values = try item.resourceValues(forKeys: [.addedToDirectoryDateKey])
    if let date = values.addedToDirectoryDate {
        results.append((date, item.lastPathComponent))
    }
}

results.sort { $0.0 > $1.0 }
for (date, name) in results {
    print("\(df.string(from: date))\t\(name)")
}
