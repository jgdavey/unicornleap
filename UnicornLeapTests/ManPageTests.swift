import Foundation
import Testing
@testable import unicornleap

/// "-s, --seconds"-style pairs found by `pattern`, whose first two capture
/// groups are the short and long names.
private func flagPairs(in text: String, pattern: String) throws -> Set<String> {
  let regex = try NSRegularExpression(pattern: pattern, options: .anchorsMatchLines)
  let range = NSRange(text.startIndex..., in: text)
  return Set(regex.matches(in: text, range: range).map { match in
    let short = (text as NSString).substring(with: match.range(at: 1))
    let long = (text as NSString).substring(with: match.range(at: 2))
    return "-\(short), --\(long)"
  })
}

// The man page is written by hand, so check that its options are the ones the
// parser actually has.
@Suite struct ManPageTests {
  @Test func documentsExactlyTheParsersOptions() throws {
    let manPage = URL(fileURLWithPath: #filePath)
      .deletingLastPathComponent().deletingLastPathComponent()
      .appendingPathComponent("unicornleap.1")
    let text = try String(contentsOf: manPage, encoding: .utf8)

    // `.It Fl s , \-seconds Ar n`
    let documented = try flagPairs(in: text, pattern: #"^\.It Fl (\w) , \\-([\w-]+)"#)
    // `  -s, --seconds <n>   Animate for n seconds.`
    let parsed = try flagPairs(in: Command.helpMessage(), pattern: #"^\s+-(\w), --([\w-]+)"#)

    #expect(parsed.count == 9)
    #expect(documented == parsed)
  }
}
