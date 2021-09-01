import HexString
import SHAKE256
import XCTest

fileprivate struct Vector: Decodable {
    let message: HexString
    let output: HexString
}

final class SHAKE256Tests: XCTestCase {
    func testLongMessages() throws {
        let url = Bundle.module.url(forResource: "LongMessages", withExtension: "json")!
        let vectors = try JSONDecoder().decode([Vector].self, from: try Data(contentsOf: url))
        
        for vector in vectors {
            var sponge = SHAKE256()
            sponge.absorb(vector.message.wrappedValue)
            let result = sponge.squeeze()
            
            XCTAssertEqual(result, vector.output.wrappedValue)
        }
    }
    
    func testLongMessagesSplit() throws {
        let url = Bundle.module.url(forResource: "LongMessages", withExtension: "json")!
        let vectors = try JSONDecoder().decode([Vector].self, from: try Data(contentsOf: url))
        
        for vector in vectors {
            let message = vector.message.wrappedValue
            
            let firstPartByteCount = Int.random(in: 0...message.count)
            
            var sponge = SHAKE256()
            sponge.absorb(message.prefix(firstPartByteCount))
            sponge.absorb(message.suffix(message.count - firstPartByteCount))
            let result = sponge.squeeze()
            
            XCTAssertEqual(result, vector.output.wrappedValue)
        }
    }
    
    func testShortMessages() throws {
        let url = Bundle.module.url(forResource: "ShortMessages", withExtension: "json")!
        let vectors = try JSONDecoder().decode([Vector].self, from: try Data(contentsOf: url))
        
        for vector in vectors {
            var sponge = SHAKE256()
            sponge.absorb(vector.message.wrappedValue)
            let result = sponge.squeeze()
            
            XCTAssertEqual(result, vector.output.wrappedValue)
        }
    }
    
    func testVariableOutput() throws {
        let url = Bundle.module.url(forResource: "VariableOutput", withExtension: "json")!
        let vectors = try JSONDecoder().decode([Vector].self, from: try Data(contentsOf: url))
        
        for vector in vectors {
            var sponge = SHAKE256()
            sponge.absorb(vector.message.wrappedValue)
            let result = sponge.squeeze(count: vector.output.wrappedValue.count)
            
            XCTAssertEqual(result, vector.output.wrappedValue)
        }
    }
    
    func testVariableOutputSplit() throws {
        let url = Bundle.module.url(forResource: "VariableOutput", withExtension: "json")!
        let vectors = try JSONDecoder().decode([Vector].self, from: try Data(contentsOf: url))
        
        for vector in vectors {
            let output = vector.output.wrappedValue
            
            var sponge = SHAKE256()
            sponge.absorb(vector.message.wrappedValue)
            let a = sponge.squeeze(count: Int.random(in: 0...output.count))
            let b = sponge.squeeze(count: output.count - a.count)
            
            XCTAssertEqual(a + b, output)
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
