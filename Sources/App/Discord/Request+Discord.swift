import Vapor

extension Request {
    var discord: DiscordWebhook {
        guard let configuration = self.application.discord.configuration else {
            fatalError("discord webhook service not configured")
        }
        return .init(
            configuration: configuration,
            client: self.client,
            logger: self.logger
        )
    }
}
