import Vapor

public func configure(_ app: Application) throws {
    app.routes.defaultMaxBodySize = "64kb"
    
    guard let githubAccessToken = Environment.get("GITHUB_ACCESS_TOKEN") else {
        fatalError("GITHUB_ACCESS_TOKEN not set in environment")
    }
    app.github.configuration = .init(personalAccessToken: githubAccessToken)

    guard let discordWebhookToken = Environment.get("DISCORD_WEBHOOK_TOKEN") else {
        fatalError("DISCORD_WEBHOOK_TOKEN not set in environment")
    }
    app.discord.configuration = .init(tokens: [
        .release: discordWebhookToken
    ])

    try routes(app)
}
