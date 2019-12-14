import Vapor

extension GitHubAPI {
    func tagNextRelease(
        bump: SemverVersion.Bump,
        owner: String,
        repo: String,
        branch: String,
        name: String,
        body: String
    ) -> EventLoopFuture<Releases.Release> {
        self.logger.info("Tagging next \(bump) release to \(owner)/\(repo)")
        return self.releases.all(owner: owner, repo: repo).flatMapThrowing { releases -> SemverVersion in
            guard let latest = releases.first else {
                throw Abort(.internalServerError, reason: "No releases yet")
            }
            guard let version = SemverVersion(string: latest.tag_name) else {
                throw Abort(.internalServerError, reason: "Tag is not valid semver version \(latest.tag_name)")
            }
            self.logger.info("Latest version of \(owner)/\(repo) is \(version)")
            return version.next(bump)
        }.flatMap { version -> EventLoopFuture<Releases.Release> in
            self.logger.info("Releasing \(owner)/\(repo) \(version)")
            return self.releases.create(
                release: .init(
                    tag_name: version.description,
                    target_commitish: branch,
                    name: name,
                    body: body,
                    draft: false,
                    prerelease: version.prerelease != nil
                ),
                owner: owner,
                repo: repo
            )
        }
    }
}
