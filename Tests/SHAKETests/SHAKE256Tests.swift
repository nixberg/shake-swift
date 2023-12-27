import Algorithms
import Blobby
import SHAKE
import XCTest

final class SHAKE256Tests: XCTestCase {
    let testVectors = try! Data(contentsOf: Bundle.module.url(
        forResource: "shake256", withExtension: "blb"
    )!).blobs().couples()
    
    func test() {
        XCTAssert(SHAKE256.hash(contentsOf: []).elementsEqual([
            0x46, 0xb9, 0xdd, 0x2b, 0x0b, 0xa8, 0x8d, 0x13,
            0x23, 0x3b, 0x3f, 0xeb, 0x74, 0x3e, 0xeb, 0x24,
            0x3f, 0xcd, 0x52, 0xea, 0x62, 0xb8, 0x1b, 0x82,
            0xb5, 0x0c, 0x27, 0x64, 0x6e, 0xd5, 0x76, 0x2f,
        ]))
    }
    
    func testBlob() {
        for (message, expectedOutput) in testVectors {
            var shake = SHAKE256()
            shake.append(contentsOf: message)
            let result = shake.squeezed()
            XCTAssert(result.starts(with: expectedOutput))
        }
    }
    
    func testBlobWithSplitMessage() {
        for (message, expectedOutput) in testVectors {
            var shake = SHAKE256()
            let count = Int.random(in: 0...message.count)
            shake.append(contentsOf: message.prefix(count))
            shake.append(contentsOf: message.dropFirst(count))
            let result = shake.squeezed().prefix(expectedOutput.count)
            XCTAssert(result.elementsEqual(expectedOutput))
        }
    }
}
