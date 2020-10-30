import XCTest
import SHAKE256

fileprivate struct Vector: Decodable {
    let message: String
    let output: String
}

final class SHAKE256Tests: XCTestCase {
    func testLongMessages() throws {
        let url = Bundle.module.url(forResource: "LongMessages", withExtension: "json")!
        let vectors = try JSONDecoder().decode([Vector].self, from: try Data(contentsOf: url))
        
        for vector in vectors {
            let message = Array(hex: vector.message)!
            let output = Array(hex: vector.output)!
            
            var sponge = SHAKE256()
            sponge.absorb(message)
            let result = sponge.squeeze()
            
            XCTAssertEqual(result, output)
        }
    }
    
    func testLongMessagesSplit() throws {
        let url = Bundle.module.url(forResource: "LongMessages", withExtension: "json")!
        let vectors = try JSONDecoder().decode([Vector].self, from: try Data(contentsOf: url))
        
        for vector in vectors {
            let message = Array(hex: vector.message)!
            let output = Array(hex: vector.output)!
            
            let firstPartByteCount = Int.random(in: 0...message.count)
            
            var sponge = SHAKE256()
            sponge.absorb(message.prefix(firstPartByteCount))
            sponge.absorb(message.suffix(message.count - firstPartByteCount))
            let result = sponge.squeeze()
            
            XCTAssertEqual(result, output)
        }
    }
    
    func testShortMessages() throws {
        let url = Bundle.module.url(forResource: "ShortMessages", withExtension: "json")!
        let vectors = try JSONDecoder().decode([Vector].self, from: try Data(contentsOf: url))
        
        for vector in vectors {
            let message = Array(hex: vector.message)!
            let output = Array(hex: vector.output)!
            
            var sponge = SHAKE256()
            sponge.absorb(message)
            let result = sponge.squeeze()
            
            XCTAssertEqual(result, output)
        }
    }
    
    func testVariableOutput() throws {
        let url = Bundle.module.url(forResource: "VariableOutput", withExtension: "json")!
        let vectors = try JSONDecoder().decode([Vector].self, from: try Data(contentsOf: url))
        
        for vector in vectors {
            let message = Array(hex: vector.message)!
            let output = Array(hex: vector.output)!
            
            var sponge = SHAKE256()
            sponge.absorb(message)
            let result = sponge.squeeze(count: output.count)
            
            XCTAssertEqual(result, output)
        }
    }
    
    func testVariableOutputSplit() throws {
        let url = Bundle.module.url(forResource: "VariableOutput", withExtension: "json")!
        let vectors = try JSONDecoder().decode([Vector].self, from: try Data(contentsOf: url))
        
        for vector in vectors {
            let message = Array(hex: vector.message)!
            let output = Array(hex: vector.output)!
            
            var sponge = SHAKE256()
            sponge.absorb(message)
            let a = sponge.squeeze(count: Int.random(in: 0...output.count))
            let b = sponge.squeeze(count: output.count - a.count)
            
            XCTAssertEqual(a + b, output)
        }
    }
}

fileprivate extension Array where Element == UInt8 {
    init?(hex: String) {
        guard hex.count.isMultiple(of: 2) else {
            return nil
        }
        
        var hex = hex[...]
        let expectedByteCount = hex.count / 2
        
        self = stride(from: 0, to: hex.count, by: 2).compactMap { _ in
            defer { hex = hex.dropFirst(2) }
            return UInt8(hex.prefix(2), radix: 16)
        }
        
        guard count == expectedByteCount else {
            return nil
        }
    }
}
