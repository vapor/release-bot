import Vapor
extension GitHubAPI {
    var issues: Issues {
        .init(github: self)
    }
    struct Issues {
        let github: GitHubAPI

        struct CreateComment: Codable {
            let body: String
        }

        func create(comment: CreateComment, owner: String, repo: String, issue: Int) -> EventLoopFuture<Void> {
            self.github.send(.POST, path: "/repos/\(owner)/\(repo)/issues/\(issue)/comments") {
                try $0.content.encode(comment, as: .json)
            }.flatMapThrowing {
                guard $0.status == .created else {
                    throw Error(reason: "failed to create comment: \($0)")
                }
            }
        }
    }
}
