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
            var sponge = SHAKE256()
            sponge.absorb(vector.message)
            let result = sponge.squeeze()
            
            XCTAssertEqual(result, vector.output)
        }
    }
    
    func testLongMessagesSplit() throws {
        let url = Bundle.module.url(forResource: "LongMessages", withExtension: "json")!
        let vectors = try JSONDecoder().decode([Vector].self, from: try Data(contentsOf: url))
        
        for vector in vectors {
            let firstPartByteCount = Int.random(in: 0...vector.message.count)
            
            var sponge = SHAKE256()
            sponge.absorb(vector.message.prefix(firstPartByteCount))
            sponge.absorb(vector.message.suffix(vector.message.count - firstPartByteCount))
            let result = sponge.squeeze()
            
            XCTAssertEqual(result, vector.output)
        }
    }
    
    func testShortMessages() throws {
        let url = Bundle.module.url(forResource: "ShortMessages", withExtension: "json")!
        let vectors = try JSONDecoder().decode([Vector].self, from: try Data(contentsOf: url))
        
        for vector in vectors {
            var sponge = SHAKE256()
            sponge.absorb(vector.message)
            let result = sponge.squeeze()
            
            XCTAssertEqual(result, vector.output)
        }
    }
    
    func testVariableOutput() throws {
        let url = Bundle.module.url(forResource: "VariableOutput", withExtension: "json")!
        let vectors = try JSONDecoder().decode([Vector].self, from: try Data(contentsOf: url))
        
        for vector in vectors {
            var sponge = SHAKE256()
            sponge.absorb(vector.message)
            let result = sponge.squeeze(count: vector.output.count)
            
            XCTAssertEqual(result, vector.output)
        }
    }
    
    func testVariableOutputSplit() throws {
        let url = Bundle.module.url(forResource: "VariableOutput", withExtension: "json")!
        let vectors = try JSONDecoder().decode([Vector].self, from: try Data(contentsOf: url))
        
        for vector in vectors {
            var sponge = SHAKE256()
            sponge.absorb(vector.message)
            let a = sponge.squeeze(count: Int.random(in: 0...vector.output.count))
            let b = sponge.squeeze(count: vector.output.count - a.count)
            
            XCTAssertEqual(a + b, vector.output)
        }
    }
    
    func testAbsorbPerformance() {
        var sponge = SHAKE256()
        let message = [UInt8](repeating: 0, count: 1024)
        
        measure {
            for _ in 0..<128 {
                sponge.absorb(message)
            }
        }
    }
    
    func testSqueezePerformance() {
        var sponge = SHAKE256()
        var output = [UInt8]()
        
        measure {
            for _ in 0..<128 {
                output.removeAll(keepingCapacity: true)
                sponge.squeeze(to: &output, count: 1024)
            }
        }
    }
}
