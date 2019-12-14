import Vapor

func routes(_ app: Application) throws {
    app.post("webhook") { req -> EventLoopFuture<HTTPStatus> in
        let notification = try req.content.decode(GitHubWebhook.Notification.self)
        if
            notification.action == "closed",
            let pr = notification.pull_request,
            pr.merged_at != nil,
            let repo = notification.repository
        {
            let bump: SemverVersion.Bump
            if pr.labels.contains(.semverMajor) {
                bump = .major
            } else if pr.labels.contains(.semverMinor) {
                bump = .minor
            } else {
                bump = .patch
            }
            return req.github.tagNextRelease(
                bump:  bump,
                owner: repo.owner.login,
                repo: repo.name,
                branch: pr.base.ref,
                name: pr.title,
                body: pr.body
            ).flatMap { release in
                let url = "https://github.com/\(repo.owner.login)/\(repo.name)/releases/tag/\(release.tag_name)"
                let comment = req.github.issues.create(
                    comment: .init(
                        body: "These changes are now available in [\(release.tag_name)](\(url))"
                    ),
                    owner: repo.owner.login,
                    repo: repo.name,
                    issue: pr.number
                )
                let discord = req.discord.post(to: .release, message: url)
                return discord.and(comment)
                    .transform(to: .ok)
            }
        } else {
            req.logger.info("Ignoring notification: \(notification.action)")
            return req.eventLoop.makeSucceededFuture(.ok)
        }
    }

    app.get("healthz") { req in
        HTTPStatus.ok
    }
}
