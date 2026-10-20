import Foundation
import Metal
import Testing
@testable import ViewIsComming

/// `Sources/ViewIsComming`, located relative to this file so the tests can read the
/// shader and Swift sources they cross-check.
private let sourcesRoot = URL(fileURLWithPath: #filePath)
    .deletingLastPathComponent()
    .deletingLastPathComponent()
    .deletingLastPathComponent()
    .appendingPathComponent("Sources/ViewIsComming")

private func files(withExtension ext: String) -> [URL] {
    let enumerator = FileManager.default.enumerator(at: sourcesRoot, includingPropertiesForKeys: nil)
    return (enumerator?.allObjects as? [URL] ?? [])
        .filter { $0.pathExtension == ext }
        .sorted { $0.path < $1.path }
}

/// Splits `text` on commas that are not nested inside parentheses or brackets.
private func topLevelArguments(_ text: String) -> [String] {
    var result: [String] = []
    var depth = 0
    var current = ""
    for character in text {
        switch character {
        case "(", "[": depth += 1
        case ")", "]": depth -= 1
        default: break
        }
        if character == "," && depth == 0 {
            result.append(current.trimmingCharacters(in: .whitespacesAndNewlines))
            current = ""
        } else {
            current.append(character)
        }
    }
    let last = current.trimmingCharacters(in: .whitespacesAndNewlines)
    if !last.isEmpty { result.append(last) }
    return result
}

/// The text between the parenthesis that opens at `open` and its matching close.
private func balancedContents(of text: String, openingAt open: String.Index) -> String? {
    var depth = 0
    var index = open
    while index < text.endIndex {
        switch text[index] {
        case "(": depth += 1
        case ")":
            depth -= 1
            if depth == 0 {
                return String(text[text.index(after: open)..<index])
            }
        default: break
        }
        index = text.index(after: index)
    }
    return nil
}

/// Every `[[ stitchable ]]` function with the Metal types of the parameters that
/// follow `position` and `layer` – the ones the Swift side has to supply.
private func stitchableFunctions() throws -> [String: (file: String, parameters: [String])] {
    let pattern = try NSRegularExpression(
        pattern: #"\[\[\s*stitchable\s*\]\]\s*half4\s+(\w+)\s*\(([^)]*)\)"#
    )
    var result: [String: (file: String, parameters: [String])] = [:]
    for url in files(withExtension: "metal") {
        let source = try String(contentsOf: url, encoding: .utf8)
        let range = NSRange(source.startIndex..., in: source)
        for match in pattern.matches(in: source, range: range) {
            let name = String(source[Range(match.range(at: 1), in: source)!])
            let parameters = topLevelArguments(String(source[Range(match.range(at: 2), in: source)!]))
                .dropFirst(2)
                .map { declaration -> String in
                    let words = declaration.split(whereSeparator: \.isWhitespace).map(String.init)
                    return words.first { $0 != "const" && $0 != "constant" } ?? declaration
                }
            result[name] = (url.lastPathComponent, Array(parameters))
        }
    }
    return result
}

private let hasMetalDevice = MTLCreateSystemDefaultDevice() != nil

@Suite("Shader library")
struct ShaderLibraryTests {
    @Test("Metal sources define stitchable functions")
    func metalSourcesAreDiscovered() throws {
        #expect(try stitchableFunctions().count > 50)
    }

    @Test("Every stitchable function is in the compiled metallib", .enabled(if: hasMetalDevice))
    func functionsAreCompiledIntoTheLibrary() throws {
        let device = try #require(MTLCreateSystemDefaultDevice())
        let library = try device.makeDefaultLibrary(bundle: ViewIsCommingShaderLibrary.bundle)
        let compiled = Set(library.functionNames)
        for (name, definition) in try stitchableFunctions() {
            #expect(compiled.contains(name), "\(name) (\(definition.file)) is missing from default.metallib")
        }
    }

    /// SwiftUI draws nothing at all once a layer effect's `maxSampleOffset` gets too large for the
    /// view (an iOS 900 x 300 pt view vanished at 0.6 x its size), so every offset has to go through
    /// `CGSize.scaled`, which caps it – or be `.zero`.
    @Test("Sample offsets are zero or capped")
    func sampleOffsetsAreCapped() throws {
        for url in files(withExtension: "swift") {
            let source = try String(contentsOf: url, encoding: .utf8)
            for line in source.split(separator: "\n") {
                guard let range = line.range(of: "maxSampleOffset:") else { continue }
                let expression = line[range.upperBound...].trimmingCharacters(in: .whitespaces)
                #expect(
                    expression == ".zero" || expression.contains(".scaled("),
                    "\(url.lastPathComponent): maxSampleOffset \(expression) is not capped"
                )
            }
        }
    }

    @Test("Swift call sites match the Metal signatures")
    func swiftCallSitesMatchMetalSignatures() throws {
        let functions = try stitchableFunctions()
        let swiftToMetal = [
            "float": "float", "float2": "float2", "float3": "float3", "float4": "float4",
        ]
        var referenced = Set<String>()

        for url in files(withExtension: "swift") {
            let source = try String(contentsOf: url, encoding: .utf8)
            var searchStart = source.startIndex
            let marker = "ViewIsCommingShaderLibrary."
            while let found = source.range(of: marker, range: searchStart..<source.endIndex) {
                searchStart = found.upperBound
                guard let open = source[found.upperBound...].firstIndex(of: "("),
                      let name = Optional(String(source[found.upperBound..<open])),
                      name.allSatisfy({ $0.isLetter || $0.isNumber }),
                      let contents = balancedContents(of: source, openingAt: open)
                else { continue }

                referenced.insert(name)
                guard let definition = functions[name] else {
                    Issue.record("\(url.lastPathComponent) calls \(name), which has no Metal function")
                    continue
                }

                let arguments = topLevelArguments(contents).map { argument -> String in
                    let kind = argument.prefix { $0 != "(" }.dropFirst()   // ".float2(" -> "float2"
                    return swiftToMetal[String(kind)] ?? String(kind)
                }
                #expect(
                    arguments == definition.parameters,
                    "\(url.lastPathComponent): \(name) passes \(arguments) but \(definition.file) expects \(definition.parameters)"
                )
            }
        }

        for name in functions.keys where !referenced.contains(name) {
            Issue.record("\(name) is defined in Metal but never used from Swift")
        }
    }
}
