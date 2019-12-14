import Vapor

extension Application {
    var github: GitHub {
        .init(application: self)
    }

    struct GitHub {
        struct Key: StorageKey {
            typealias Value = GitHubAPI.Configuration
        }
        var configuration: GitHubAPI.Configuration? {
            get {
                self.application.storage[Key.self]
            }
            nonmutating set {
                self.application.storage[Key.self] = newValue
            }
        }

        let application: Application
    }
}
