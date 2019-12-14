import Vapor

extension GitHubAPI {
    var releases: Releases {
        .init(github: self)
    }

    struct Releases {
        struct Release: Codable {
            let name: String
            let tag_name: String
        }

        struct CreateRelease: Codable {
            let tag_name: String
            let target_commitish: String?
            let name: String?
            let body: String?
            let draft: Bool?
            let prerelease: Bool?
        }

        let github: GitHubAPI

        func all(owner: String, repo: String) -> EventLoopFuture<[Release]> {
            self.github.send(.GET, path: "/repos/\(owner)/\(repo)/releases").flatMapThrowing {
                guard $0.status == .ok else {
                    throw Error(reason: "Could not get all releases: \($0)")
                }
                return try $0.content.decode([Release].self)
            }
        }

        func latest(owner: String, repo: String) -> EventLoopFuture<Release> {
            self.github.send(.GET, path: "/repos/\(owner)/\(repo)/releases/latest").flatMapThrowing {
                guard $0.status == .ok else {
                    throw Error(reason: "Could not get latest release: \($0)")
                }
                return try $0.content.decode(Release.self)
            }
        }

        func create(release: CreateRelease, owner: String, repo: String) -> EventLoopFuture<Release> {
            self.github.send(.POST, path: "/repos/\(owner)/\(repo)/releases") {
                try $0.content.encode(release, as: .json)
            }.flatMapThrowing {
                guard $0.status == .created else {
                    throw Error(reason: "Could not get create release: \($0)")
                }
                return try $0.content.decode(Release.self)
            }
        }
    }
}
