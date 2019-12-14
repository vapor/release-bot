import Vapor

struct GitHubAPI {
    struct Configuration {
        let personalAccessToken: String
    }

    struct Error: Swift.Error {
        let reason: String
    }

    let configuration: Configuration
    let client: Client
    let logger: Logger

    func send(
        _ method: HTTPMethod,
        path: String,
        beforeSend: (inout ClientRequest) throws -> () = { _ in }
    ) -> EventLoopFuture<ClientResponse> {
        self.logger.info("[GitHub] \(method) \(path)")
        return self.client.send(method, to: URI(string: "https://api.github.com\(path)")) {
            $0.headers.add(name: .userAgent, value: "vapor/release-bot v1")
            $0.headers.basicAuthorization = .init(
                username: "tanner0101",
                password: self.configuration.personalAccessToken
            )
            try beforeSend(&$0)
        }
    }
}
