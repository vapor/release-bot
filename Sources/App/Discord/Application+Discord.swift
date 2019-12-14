import Vapor

extension Application {
    var discord: Discord {
        .init(application: self)
    }

    struct Discord {
        struct Key: StorageKey {
            typealias Value = DiscordWebook.Configuration
        }
        var configuration: DiscordWebook.Configuration? {
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
