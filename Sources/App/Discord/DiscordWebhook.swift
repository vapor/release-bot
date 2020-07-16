import Vapor

struct DiscordWebook {
    struct Configuration {
        let tokens: [Identifier: String]
    }

    struct Identifier: Hashable, Equatable {
        static var release: Self {
            .init(string: "655226809251528708")
        }
        let string: String
    }

    struct Error: Swift.Error {
        let reason: String
    }

    let configuration: Configuration
    let client: Client
    let logger: Logger

    func post(to identifier: Identifier, message: String) -> EventLoopFuture<Void> {
        guard let token = self.configuration.tokens[identifier] else {
            return self.client.eventLoop.next()
                .makeFailedFuture(Error(reason: "No token for this webhook"))
        }
        let url = "https://discordapp.com/api/webhooks/\(identifier.string)/\(token)?wait=true"
        self.logger.info("[Discord] POST \(identifier.string) \(message)")
        return self.client.post(URI(string: url)) {
            try $0.content.encode(["content": message])
        }.flatMapThrowing {
            guard $0.status == .ok else {
                throw Error(reason: "Failed to post Discord message: \($0)")
            }
        }.transform(to: ())
    }
}
