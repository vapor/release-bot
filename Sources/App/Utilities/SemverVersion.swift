struct SemverVersion {
    enum Bump {
        case major
        case minor
        case patch
    }

    struct Prerelease {
        var name: String
        var major: Int?
        var minor: Int?
    }

    var major: Int
    var minor: Int
    var patch: Int
    var prerelease: Prerelease?

    init?(string: String) {
        // 1.2.3-beta.4.5
        let parts = string.split(separator: "-")
        switch parts.count {
        case 1, 2:
            // 1.2.3
            let version = parts[0].split(separator: ".")
            switch version.count {
            case 3:
                guard let major = Int(version[0]) else {
                    return nil
                }
                self.major = major
                guard let minor = Int(version[1]) else {
                    return nil
                }
                self.minor = minor
                guard let patch = Int(version[2]) else {
                    return nil
                }
                self.patch = patch
            default:
                return nil
            }
            switch parts.count {
            case 2:
                let prerelease = parts[1].split(separator: ".")
                switch prerelease.count {
                case 1, 2, 3:
                    let name = String(prerelease[0])
                    let major: Int?
                    let minor: Int?
                    switch prerelease.count {
                    case 2, 3:
                        guard let m = Int(prerelease[1]) else {
                            return nil
                        }
                        major = m
                        switch prerelease.count {
                        case 3:
                            guard let mi = Int(prerelease[2]) else {
                                return nil
                            }
                            minor = mi
                        default:
                            minor = nil
                        }
                    default:
                        major = nil
                        minor = nil
                    }
                    self.prerelease = Prerelease(
                        name: name,
                        major: major,
                        minor: minor
                    )
                default:
                    return nil
                }
            default:
                self.prerelease = nil
            }
        default:
            return nil
        }
    }

    func next(_ bump: Bump) -> SemverVersion {
        var version = self
        if var prerelease = version.prerelease {
            switch bump {
            case .patch, .minor:
                if let existing = prerelease.minor {
                    prerelease.minor = existing + 1
                } else {
                    prerelease.minor = 1
                }
            case .major:
                prerelease.minor = nil
                if let existing = prerelease.major {
                    prerelease.major = existing + 1
                } else {
                    prerelease.major = 1
                }
            }
            version.prerelease = prerelease
        } else {
            switch bump {
            case .patch:
                version.patch += 1
            case .minor:
                version.patch = 0
                version.minor += 1
            case .major:
                version.patch = 0
                version.minor = 0
                version.major += 1
            }
        }
        return version
    }
}

extension SemverVersion.Prerelease: Comparable {
    static func < (lhs: SemverVersion.Prerelease, rhs: SemverVersion.Prerelease) -> Bool {
        lhs.name < rhs.name
            && (lhs.major ?? 0) < (rhs.major ?? 0)
            && (lhs.minor ?? 0) < (rhs.minor ?? 0)
    }
}

extension SemverVersion: Comparable {
    static func < (lhs: SemverVersion, rhs: SemverVersion) -> Bool {
        if lhs.major < rhs.major {
            return true
        } else if lhs.major == rhs.major && lhs.minor < rhs.minor {
            return true
        } else if lhs.major == rhs.major && lhs.minor == rhs.minor && lhs.patch < rhs.patch {
            return true
        } else if let lpr = lhs.prerelease,
            lhs.major == rhs.major, lhs.minor == rhs.minor, lhs.patch == rhs.patch
        {
            if let rpr = rhs.prerelease {
                return lpr < rpr
            } else {
                return true
            }
        } else {
            return false
        }
    }

    static func == (lhs: SemverVersion, rhs: SemverVersion) -> Bool {
        lhs.major == rhs.major
            && lhs.minor == rhs.minor
            && lhs.patch == rhs.patch
            && lhs.prerelease == rhs.prerelease
    }
}

extension SemverVersion: CustomStringConvertible {
    var description: String {
        var description = "\(self.major).\(self.minor).\(self.patch)"
        if let prerelease = self.prerelease {
            description += "-\(prerelease.name)"
            if let major = prerelease.major {
                description += ".\(major)"
            }
            if let minor = prerelease.minor {
                description += ".\(minor)"
            }
        }
        return description
    }
}
