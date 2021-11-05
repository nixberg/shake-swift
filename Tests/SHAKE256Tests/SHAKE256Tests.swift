import Algorithms
import HexString
import SHAKE256
import XCTest

fileprivate struct Vector: Decodable {
    @HexString var message: [UInt8]
    @HexString var output: [UInt8]
}

final class SHAKE256Tests: XCTestCase {
    func testLongMessages() throws {
        let url = Bundle.module.url(forResource: "LongMessages", withExtension: "json")!
        let vectors = try JSONDecoder().decode([Vector].self, from: try Data(contentsOf: url))
        
        for vector in vectors {
            XCTAssertEqual(SHAKE256.hash(contentsOf: vector.message), vector.output)
        }
    }
    
    func testLongMessagesSplit() throws {
        let url = Bundle.module.url(forResource: "LongMessages", withExtension: "json")!
        let vectors = try JSONDecoder().decode([Vector].self, from: try Data(contentsOf: url))
        
        for vector in vectors {
            let count = Int.random(in: 0...vector.message.count)
            
            var shake256 = SHAKE256()
            shake256.absorb(contentsOf: vector.message.prefix(count))
            shake256.absorb(contentsOf: vector.message.dropFirst(count))
            XCTAssertEqual(shake256.squeeze(), vector.output)
        }
    }
    
    func testShortMessages() throws {
        let url = Bundle.module.url(forResource: "ShortMessages", withExtension: "json")!
        let vectors = try JSONDecoder().decode([Vector].self, from: try Data(contentsOf: url))
        
        for vector in vectors {
            XCTAssertEqual(SHAKE256.hash(contentsOf: vector.message), vector.output)
        }
    }
    
    func testVariableOutput() throws {
        let url = Bundle.module.url(forResource: "VariableOutput", withExtension: "json")!
        let vectors = try JSONDecoder().decode([Vector].self, from: try Data(contentsOf: url))
        
        for vector in vectors {
            XCTAssertEqual(
                SHAKE256.hash(contentsOf: vector.message, outputByteCount: vector.output.count),
                vector.output)
        }
    }
    
    func testVariableOutputSplit() throws {
        let url = Bundle.module.url(forResource: "VariableOutput", withExtension: "json")!
        let vectors = try JSONDecoder().decode([Vector].self, from: try Data(contentsOf: url))
        
        for vector in vectors {
            let count = Int.random(in: 1..<vector.output.count)
            
            var shake256 = SHAKE256()
            shake256.absorb(contentsOf: vector.message)
            let a = shake256.squeeze(outputByteCount: count)
            let b = shake256.squeeze(outputByteCount: vector.output.count - count)
            XCTAssert(chain(a, b).elementsEqual(vector.output))
        }
    }
}
