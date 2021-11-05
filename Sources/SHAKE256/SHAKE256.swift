import Algorithms
import Collections
import Duplex
import EndianBytes

public struct SHAKE256: Duplex {
    public typealias Output = [UInt8]
    
    public static let defaultOutputByteCount = 32
    
    static let bitRate  = 1088
    static let byteRate = bitRate / UInt8.bitWidth
    static let wordRate = bitRate / UInt64.bitWidth
    
    private var state: State = .init()
    private var buffer: Deque<UInt8> = .init(minimumCapacity: Self.byteRate)
    
    private var isAbsorbing = true
    
    public init() {}
    
    public mutating func absorb<Bytes>(contentsOf bytes: Bytes)
    where Bytes: Sequence, Bytes.Element == UInt8 {
        assert((0..<Self.byteRate).contains(buffer.count))
        precondition(isAbsorbing, "SHAKE256: absorb(contentsOf:) called after squeeze.")
        
        for byte in bytes {
            buffer.append(byte)
            if buffer.count == Self.byteRate {
                state.xor(contentsOf: buffer)
                buffer.removeAll(keepingCapacity: true)
                state.permute()
            }
        }
    }
    
    public mutating func squeeze<Output>(to output: inout Output, outputByteCount: Int)
    where Output: RangeReplaceableCollection, Output.Element == UInt8 {
        precondition(outputByteCount >= 0)
        
        assert((0..<Self.byteRate).contains(buffer.count))
        
        if isAbsorbing {
            buffer.append(0x1f)
            buffer.padEnd(with: 0, toCount: Self.byteRate)
            buffer[buffer.count - 1] ^= 0x80
            
            state.xor(contentsOf: buffer)
            buffer.removeAll(keepingCapacity: true)
            
            isAbsorbing = false
        }
        
        for _ in 0..<outputByteCount {
            if buffer.isEmpty {
                state.permute()
                for word in state.prefix(Self.wordRate) {
                    buffer.append(contentsOf: word.littleEndianBytes())
                }
            }
            output.append(buffer.popFirst()!)
        }
    }
    
    public mutating func squeeze(outputByteCount: Int) -> Self.Output {
        var output: [UInt8] = []
        output.reserveCapacity(outputByteCount)
        self.squeeze(to: &output, outputByteCount: outputByteCount)
        return output
    }
}

// TODO: Remove when available in Algorithms.
fileprivate extension RangeReplaceableCollection {
    mutating func padEnd(with element: Element, toCount paddedCount: Int) {
        let padElementCount = paddedCount - count
        guard padElementCount > 0 else {
            return
        }
        self.append(contentsOf: repeatElement(element, count: padElementCount))
    }
}
