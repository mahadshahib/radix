// swift-tools-version:5.4
import PackageDescription

let package = Package(
    name: "Radix",
    products: [
        .library(
            name: "Hex",
            targets: ["Hex"]),
        .library(
            name: "Base64",
            targets: ["Base64"]),
    ],
    dependencies: [
        .package(name: "Test")
    ],
    targets: [
        .target(
            name: "Hex",
            dependencies: []),
        .target(
            name: "Base64",
            dependencies: []),
        .executableTarget(
            name: "Tests/Hex",
            dependencies: ["Test", "Hex"],
            path: "Tests/Hex"),
        .executableTarget(
            name: "Tests/Base64",
            dependencies: ["Test", "Base64"],
            path: "Tests/Base64"),
    ]
)

// MARK: - custom package source

#if canImport(ObjectiveC)
import Darwin.C
#else
import Glibc
#endif

extension Package.Dependency {
    enum Source: String {
        case local, remote, github

        static var `default`: Self { .github }

        var baseUrl: String {
            switch self {
            case .local: return "../"
            case .remote: return "https://swiftstack.io/"
            case .github: return "https://github.com/swiftstack/"
            }
        }

        func url(for name: String) -> String {
            return self == .local
                ? baseUrl + name.lowercased()
                : baseUrl + name.lowercased() + ".git"
        }
    }

    static func package(name: String) -> Package.Dependency {
        guard let pointer = getenv("SWIFTSTACK") else {
            return .package(name: name, source: .default)
        }
        guard let source = Source(rawValue: String(cString: pointer)) else {
            fatalError("Invalid source. Use local, remote or github")
        }
        return .package(name: name, source: source)
    }

    static func package(name: String, source: Source) -> Package.Dependency {
        return source == .local
            ? .package(name: name, path: source.url(for: name))
            : .package(name: name, url: source.url(for: name), .branch("dev"))
    }
}
