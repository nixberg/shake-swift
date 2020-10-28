import Foundation

public struct SHAKE256 {
    public static let defaultOutputByteCount = 32
    
    private static let bitRate = 1088
    private static let byteRate = bitRate / 8
    
    private var state: [UInt64]
    private var buffer: [UInt8]
    private var bufferView: ArraySlice<UInt8>
    private var isAbsorbing = true
    
    public init() {
        state = .init(repeating: 0, count: 25)
        buffer = []
        buffer.reserveCapacity(Self.byteRate)
        bufferView = buffer[...]
    }
    
    public mutating func absorb<Input>(_ input: Input) where Input: DataProtocol {
        precondition(isAbsorbing, "SHAKE256: absorb(_:) called after squeeze.")
        
        var input = input[...]
        
        while !input.isEmpty {
            if buffer.isEmpty && input.count >= Self.byteRate {
                self.xorToState(input)
                input = input.dropFirst(Self.byteRate)
                self.permute()
                continue
            }
            
            let bytesWanted = Self.byteRate - buffer.count
            buffer.append(contentsOf: input.prefix(bytesWanted))
            input = input.dropFirst(bytesWanted)
            
            if buffer.count == Self.byteRate {
                self.xorToState(buffer)
                buffer.removeAll(keepingCapacity: true)
                self.permute()
            }
        }
    }
    
    public mutating func squeeze<Output>(to output: inout Output)
    where Output: MutableDataProtocol {
        self.squeeze(count: Self.defaultOutputByteCount, to: &output)
    }
    
    public mutating func squeeze<Output>(count: Int, to output: inout Output)
    where Output: MutableDataProtocol {
        precondition(count >= 0)
        
        if isAbsorbing {
            buffer.append(0x1f)
            buffer.append(contentsOf: repeatElement(0, count: Self.byteRate - buffer.count))
            buffer[buffer.count - 1] ^= 0x80
            
            self.xorToState(buffer)
            buffer.removeAll(keepingCapacity: true)
            
            isAbsorbing = false
        }
        
        var count = count
        
        while count > 0 {
            if bufferView.isEmpty {
                self.permute()
                
                buffer.removeAll(keepingCapacity: true)
                
                for word in state.prefix(Self.bitRate / UInt64.bitWidth) {
                    buffer.append(contentsOf: stride(from: 0, to: UInt64.bitWidth, by: 8).map {
                        UInt8(truncatingIfNeeded: word &>> $0)
                    })
                }
                
                bufferView = buffer[...]
            }
            
            let bytesSqueezed = min(bufferView.count, count)
            output.append(contentsOf: bufferView.prefix(bytesSqueezed))
            bufferView = bufferView.dropFirst(bytesSqueezed)
            count -= bytesSqueezed
        }
    }
    
    public mutating func squeeze() -> [UInt8] {
        self.squeeze(count: Self.defaultOutputByteCount)
    }
    
    public mutating func squeeze(count: Int) -> [UInt8] {
        var output = [UInt8]()
        output.reserveCapacity(count)
        self.squeeze(count: count, to: &output)
        return output
    }
    
    private mutating func xorToState<Input>(_ input: Input) where Input: DataProtocol {
        var input = input[...]
        for i in 0..<(Self.bitRate / UInt64.bitWidth) {
            state[i] ^= UInt64(littleEndianBytes: input.prefix(UInt64.bitWidth / 8))
            input = input.dropFirst(UInt64.bitWidth / 8)
        }
    }
    
    private mutating func permute() {
        precondition(state.count == 25)
        
        let roundConstants: [UInt64] = [
            0x0000000000000001, 0x0000000000008082, 0x800000000000808a, 0x8000000080008000,
            0x000000000000808b, 0x0000000080000001, 0x8000000080008081, 0x8000000000008009,
            0x000000000000008a, 0x0000000000000088, 0x0000000080008009, 0x000000008000000a,
            0x000000008000808b, 0x800000000000008b, 0x8000000000008089, 0x8000000000008003,
            0x8000000000008002, 0x8000000000000080, 0x000000000000800a, 0x800000008000000a,
            0x8000000080008081, 0x8000000000008080, 0x0000000080000001, 0x8000000080008008,
        ]
        
        for roundConstant in roundConstants {
            
            // Theta:
            
            var a = state[0] ^ state[5] ^ state[10] ^ state[15] ^ state[20]
            var b = state[1] ^ state[6] ^ state[11] ^ state[16] ^ state[21]
            var c = state[2] ^ state[7] ^ state[12] ^ state[17] ^ state[22]
            var d = state[3] ^ state[8] ^ state[13] ^ state[18] ^ state[23]
            var e = state[4] ^ state[9] ^ state[14] ^ state[19] ^ state[24]
            
            var temp: UInt64
            
            temp = e ^ b.rotated(left: 1)
            state[ 0] ^= temp
            state[ 5] ^= temp
            state[10] ^= temp
            state[15] ^= temp
            state[20] ^= temp
            temp = a ^ c.rotated(left: 1)
            state[ 1] ^= temp
            state[ 6] ^= temp
            state[11] ^= temp
            state[16] ^= temp
            state[21] ^= temp
            temp = b ^ d.rotated(left: 1)
            state[ 2] ^= temp
            state[ 7] ^= temp
            state[12] ^= temp
            state[17] ^= temp
            state[22] ^= temp
            temp = c ^ e.rotated(left: 1)
            state[ 3] ^= temp
            state[ 8] ^= temp
            state[13] ^= temp
            state[18] ^= temp
            state[23] ^= temp
            temp = d ^ a.rotated(left: 1)
            state[ 4] ^= temp
            state[ 9] ^= temp
            state[14] ^= temp
            state[19] ^= temp
            state[24] ^= temp
            
            // Rho and pi:
            
            temp = state[1]
            a = state[10]
            state[10] = temp.rotated(left: 1)
            temp = a
            a = state[7]
            state[7] = temp.rotated(left: 3)
            temp = a
            a = state[11]
            state[11] = temp.rotated(left: 6)
            temp = a
            a = state[17]
            state[17] = temp.rotated(left: 10)
            temp = a
            a = state[18]
            state[18] = temp.rotated(left: 15)
            temp = a
            a = state[3]
            state[3] = temp.rotated(left: 21)
            temp = a
            a = state[5]
            state[5] = temp.rotated(left: 28)
            temp = a
            a = state[16]
            state[16] = temp.rotated(left: 36)
            temp = a
            a = state[8]
            state[8] = temp.rotated(left: 45)
            temp = a
            a = state[21]
            state[21] = temp.rotated(left: 55)
            temp = a
            a = state[24]
            state[24] = temp.rotated(left: 2)
            temp = a
            a = state[4]
            state[4] = temp.rotated(left: 14)
            temp = a
            a = state[15]
            state[15] = temp.rotated(left: 27)
            temp = a
            a = state[23]
            state[23] = temp.rotated(left: 41)
            temp = a
            a = state[19]
            state[19] = temp.rotated(left: 56)
            temp = a
            a = state[13]
            state[13] = temp.rotated(left: 8)
            temp = a
            a = state[12]
            state[12] = temp.rotated(left: 25)
            temp = a
            a = state[2]
            state[2] = temp.rotated(left: 43)
            temp = a
            a = state[20]
            state[20] = temp.rotated(left: 62)
            temp = a
            a = state[14]
            state[14] = temp.rotated(left: 18)
            temp = a
            a = state[22]
            state[22] = temp.rotated(left: 39)
            temp = a
            a = state[9]
            state[9] = temp.rotated(left: 61)
            temp = a
            a = state[6]
            state[6] = temp.rotated(left: 20)
            temp = a
            a = state[1]
            state[1] = temp.rotated(left: 44)
            
            // Chi:
            
            a = state[0]
            b = state[1]
            c = state[2]
            d = state[3]
            e = state[4]
            state[0] ^= ~b & c
            state[1] ^= ~c & d
            state[2] ^= ~d & e
            state[3] ^= ~e & a
            state[4] ^= ~a & b
            a = state[5]
            b = state[6]
            c = state[7]
            d = state[8]
            e = state[9]
            state[5] ^= ~b & c
            state[6] ^= ~c & d
            state[7] ^= ~d & e
            state[8] ^= ~e & a
            state[9] ^= ~a & b
            a = state[10]
            b = state[11]
            c = state[12]
            d = state[13]
            e = state[14]
            state[10] ^= ~b & c
            state[11] ^= ~c & d
            state[12] ^= ~d & e
            state[13] ^= ~e & a
            state[14] ^= ~a & b
            a = state[15]
            b = state[16]
            c = state[17]
            d = state[18]
            e = state[19]
            state[15] ^= ~b & c
            state[16] ^= ~c & d
            state[17] ^= ~d & e
            state[18] ^= ~e & a
            state[19] ^= ~a & b
            a = state[20]
            b = state[21]
            c = state[22]
            d = state[23]
            e = state[24]
            state[20] ^= ~b & c
            state[21] ^= ~c & d
            state[22] ^= ~d & e
            state[23] ^= ~e & a
            state[24] ^= ~a & b
            
            // Iota:
            
            state[0] ^= roundConstant
        }
    }
}

fileprivate extension UInt64 {
    @inline(__always)
    init<D>(littleEndianBytes bytes: D) where D: DataProtocol {
        assert(bytes.count == Self.bitWidth / 8)
        self = bytes.reversed().reduce(0, { $0 &<< 8 | Self($1) })
    }
    
    @inline(__always)
    func rotated(left count: Int) -> Self {
        (self &<< count) | (self &>> (Self.bitWidth - count))
    }
}

//func printUnrolledRound() {
//    let bc = ["a", "b", "c", "d", "e"]
//
//    let pi = [
//        10,  7, 11, 17, 18,  3,  5, 16,
//         8, 21, 24,  4, 15, 23, 19, 13,
//        12,  2, 20, 14, 22,  9,  6,  1,
//    ]
//
//    let rho = [
//         1,  3,  6, 10, 15, 21, 28, 36,
//        45, 55,  2, 14, 27, 41, 56,  8,
//        25, 43, 62, 18, 39, 61, 20, 44,
//    ]
//
//    print("// Theta:")
//    print("")
//
//    for i in 0..<5 {
//        print("let \(bc[i]) = state[\(i)] ^ state[\(i + 5)] ^ " +
//                "state[\(i + 10)] ^ state[\(i + 15)] ^ state[\(i + 20)]")
//    }
//
//    print("")
//
//    for i in 0..<5 {
//        print("let temp = \(bc[(i + 4) % 5]) ^ \(bc[(i + 1) % 5]).rotated(left: 1)")
//        for j in stride(from: 0, to: 25, by: 5) {
//            print("state[\(j + i)] ^= temp")
//        }
//    }
//
//    print("")
//    print("// Rho and pi:")
//    print("")
//
//    print("var last = state[1]")
//    for i in 0..<24 {
//        print("\(bc[0]) = state[\(pi[i])]")
//        print("state[\(pi[i])] = last.rotated(left: \(rho[i]))")
//        print("last = \(bc[0])")
//    }
//
//    print("")
//    print("// Chi:")
//    print("")
//
//    for j in stride(from: 0, to: 25, by: 5) {
//        for i in 0..<5 {
//            print("\(bc[i]) = state[\(j + i)]")
//        }
//        for i in 0..<5 {
//            print("state[\(j + i)] ^= ~\(bc[(i + 1) % 5]) & \(bc[(i + 2) % 5])")
//        }
//    }
//
//    print("")
//    print("// Iota:")
//    print("")
//
//    print("state[0] ^= roundConstant")
//}
