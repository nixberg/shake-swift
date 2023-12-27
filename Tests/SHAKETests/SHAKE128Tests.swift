import Algorithms
import Blobby
import SHAKE
import XCTest

final class SHAKE128Tests: XCTestCase {
    let testVectors = try! Data(contentsOf: Bundle.module.url(
        forResource: "shake128", withExtension: "blb"
    )!).blobs().couples()
    
    func test() {
        XCTAssert(SHAKE128.hash(contentsOf: []).elementsEqual([
            0x7f, 0x9c, 0x2b, 0xa4, 0xe8, 0x8f, 0x82, 0x7d,
            0x61, 0x60, 0x45, 0x50, 0x76, 0x05, 0x85, 0x3e,
            0xd7, 0x3b, 0x80, 0x93, 0xf6, 0xef, 0xbc, 0x88,
            0xeb, 0x1a, 0x6e, 0xac, 0xfa, 0x66, 0xef, 0x26,
        ]))
    }
    
    func testBlob() {
        for (message, expectedOutput) in testVectors {
            var shake = SHAKE128()
            shake.append(contentsOf: message)
            let result = shake.squeezed()
            XCTAssert(result.starts(with: expectedOutput))
        }
    }
    
    func testBlobWithSplitMessage() {
        for (message, expectedOutput) in testVectors {
            var shake = SHAKE128()
            let count = Int.random(in: 0...message.count)
            shake.append(contentsOf: message.prefix(count))
            shake.append(contentsOf: message.dropFirst(count))
            let result = shake.squeezed()
            XCTAssert(result.starts(with: expectedOutput))
        }
    }
}
