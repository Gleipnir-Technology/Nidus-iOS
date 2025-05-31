//
//  Importer.swift
//  Nidus Notes
//
//  Created by Eli Ribble on 5/31/25.
//
import SwiftData

/*
actor BackgroundImporter {
    var modelContainer: ModelContainer

    init(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
    }

    func backgroundInsert() async throws {
        let modelContext = ModelContext(modelContainer)

        let batchSize = 1000
        let totalObjects = 100_000

        for i in 0..<(totalObjects / batchSize) {
            for j in 0..<batchSize {
                // try await Task.sleep(for: .milliseconds(1))
                let issue = Movie(title: "Movie \(I * batchSize + j)", cast: [])
                modelContext.insert(issue)
            }

            try modelContext.save()
        }
    }
}
*/
