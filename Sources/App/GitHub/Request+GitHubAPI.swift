import Vapor

extension Request {
    var github: GitHubAPI {
        guard let configuration = self.application.github.configuration else {
            fatalError("GitHub API service not configured")
        }
        return .init(configuration: configuration, client: self.client, logger: self.logger)
    }
}
