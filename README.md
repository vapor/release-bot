# Release Bot

This simple Vapor app listens for "PR merged" webhook notifications from GitHub. When it sees a PR is merged, it creates a new release on the target repo. The version number of the latest release will be bumped automatically depending on whether the PR has `semver-major`, `-minor`, or `-patch` labels. Once the release has been created, a link to the release will be posted as a comment to the PR as well as to Discord. 
