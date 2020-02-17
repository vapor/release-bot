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
            // Parse release versions, sorting by latest first.
            let versions = releases.compactMap {
                SemverVersion(string: $0.tag_name)
            }.filter {
                guard let majorVersion = Int(branch) else {
                    return true
                }
                // If the branch name is an integer, only include releases
                // for that major version.
                return $0.major == majorVersion
            }.sorted { $0 > $1 }
            guard let version = versions.first else {
                throw Abort(.internalServerError, reason: "No releases yet")
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
