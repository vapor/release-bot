#!/usr/bin/swift
import Foundation

// MARK: - Script variables
let awsProfileName: String? = nil//"vapor-deployer"
let serviceName = "vapor-release-bot"

// MARK: - Functions
@discardableResult
func shell(_ args: String..., returnStdOut: Bool = false, stdIn: Pipe? = nil) -> (Int32, Pipe) {
    return shell(args, returnStdOut: returnStdOut, stdIn: stdIn)
}

@discardableResult
func shell(_ args: [String], returnStdOut: Bool = false, stdIn: Pipe? = nil) -> (Int32, Pipe) {
    let task = Process()
    task.launchPath = "/usr/bin/env"
    task.arguments = args
    let pipe = Pipe()
    if returnStdOut {
        task.standardOutput = pipe
    }
    if let stdIn = stdIn {
        task.standardInput = stdIn
    }
    task.launch()
    task.waitUntilExit()
    return (task.terminationStatus, pipe)
}

extension Pipe {
    func string() -> String? {
        let data = self.fileHandleForReading.readDataToEndOfFile()
        let result: String?
        if let string = String(data: data, encoding: String.Encoding.utf8) {
            result = string
        } else {
            result = nil
        }
        return result
    }
}

// MARK: - Codable Types
// MARK: - Script

if let profileName = awsProfileName {
    print("ℹ️  Will use profile \(profileName) for AWS actions")
} else {
    print("ℹ️  Will use no profile for AWS actions")
}

print("Buidling lambda image")
let buildCommands = ["./scripts/build-and-package.sh", "Run"]
let (buildResult, _) = shell(buildCommands, returnStdOut: false)
guard buildResult == 0 else {
    print("❌ ERROR: Failed to build Lambda image")
    exit(1)
}

let hashCommand = ["shasum", ".build/lambda/Run/lambda.zip"]
let (hashResult, hashOutputPipe) = shell(hashCommand, returnStdOut: true)
guard hashResult == 0, let hashOutput = hashOutputPipe.string() else {
    print("❌ ERROR: Failed to hash Lambda image")
    exit(1)
}

let hashParts = hashOutput.split(separator: " ")
let hash = hashParts.first!

let dateFormatter = DateFormatter()
dateFormatter.dateFormat = "yyMMdd"
let date = dateFormatter.string(from: Date())

let newFilename = "lambda-\(date)-\(hash).zip"

try FileManager().copyItem(atPath: ".build/lambda/Run/lambda.zip", toPath: newFilename)

defer {
    // Clean up uploaded Zip
    try? FileManager().removeItem(atPath: newFilename)
}

print("⛅️ Uploading to S3...")

var uploadToS3Args = ["aws", "s3", "cp", "\(newFilename)", "s3://vapor-lambda-functions/vapor-release-bot/\(newFilename)"]
if let profile = awsProfileName {
    uploadToS3Args.append(contentsOf: ["--profile", profile])
}

let (uploadResult, _) = shell(uploadToS3Args, returnStdOut: true)
guard uploadResult == 0 else {
    print("❌ ERROR: Failed to upload to S3")
    exit(1)
}

print("🚀 Deploying CF stack...")

let stackName = "\(serviceName)-stack"
var deployStackArgs = ["aws", "cloudformation", "deploy", "--stack-name", stackName, "--template-file", "deploy/deploy.yaml", "--parameter-overrides", "Filename=\(newFilename)", "--capabilities", "CAPABILITY_NAMED_IAM"]
if let profile = awsProfileName {
    deployStackArgs.append(contentsOf: ["--profile", profile])
}
let (deployStackResult, _) = shell(deployStackArgs, returnStdOut: true)
guard deployStackResult == 0 else {
    print("❌ ERROR: Failed to deploy stack \(stackName)")
    exit(1)
}

print("✅  Stack \(stackName) deployed")