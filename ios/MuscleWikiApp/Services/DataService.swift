import Foundation

enum DataServiceError: LocalizedError {
    case fileNotFound(String)
    case decodingFailed(String, Error)

    var errorDescription: String? {
        switch self {
        case .fileNotFound(let name):
            return "Bundle resource '\(name)' not found."
        case .decodingFailed(let name, let error):
            return "Failed to decode '\(name)': \(error.localizedDescription)"
        }
    }
}

actor DataService {
    static let shared = DataService()
    private init() {}

    func loadExercises() async throws -> [Exercise] {
        try await load(resource: "workout-data", type: [Exercise].self)
    }

    func loadAttributes() async throws -> WorkoutAttributes {
        try await load(resource: "workout-attributes", type: WorkoutAttributes.self)
    }

    // MARK: Private

    private func load<T: Decodable>(resource: String, type: T.Type) async throws -> T {
        guard let url = Bundle.main.url(forResource: resource, withExtension: "json") else {
            throw DataServiceError.fileNotFound(resource)
        }
        do {
            let data = try Data(contentsOf: url)
            return try JSONDecoder().decode(T.self, from: data)
        } catch let error as DataServiceError {
            throw error
        } catch {
            throw DataServiceError.decodingFailed(resource, error)
        }
    }
}
