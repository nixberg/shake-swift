struct State: RandomAccessCollection {
    typealias Element = UInt64
    
    typealias Index = Int
    
    private var state: (
        UInt64, UInt64, UInt64, UInt64, UInt64,
        UInt64, UInt64, UInt64, UInt64, UInt64,
        UInt64, UInt64, UInt64, UInt64, UInt64,
        UInt64, UInt64, UInt64, UInt64, UInt64,
        UInt64, UInt64, UInt64, UInt64, UInt64
    ) = (
             0,      0,      0,      0,      0,
             0,      0,      0,      0,      0,
             0,      0,      0,      0,      0,
             0,      0,      0,      0,      0,
             0,      0,      0,      0,      0
    )
    
    @inline(__always)
    var count: Int {
        25
    }
    
    @inline(__always)
    var startIndex: Self.Index {
        0
    }
        
    @inline(__always)
    var endIndex: Self.Index {
        25
    }
    
    @inline(__always)
    func index(after i: Self.Index) -> Self.Index {
        assert((startIndex..<endIndex).contains(i))
        return i + 1
    }
    
    @inline(__always)
    func index(before i: Self.Index) -> Self.Index {
        assert(((startIndex + 1)..<endIndex).contains(i))
        return i + 1
    }
    
    @inline(__always)
    subscript(position: Self.Index) -> Self.Element {
        get {
            assert((startIndex..<endIndex).contains(position))
            return withUnsafePointer(to: state) {
                $0.withMemoryRebound(to: UInt64.self, capacity: 25) {
                    $0[position]
                }
            }
        }
        set {
            assert((startIndex..<endIndex).contains(position))
            withUnsafeMutablePointer(to: &state) {
                $0.withMemoryRebound(to: UInt64.self, capacity: 25) {
                    $0[position] = newValue
                }
            }
        }
    }
    
    mutating func xor<Bytes>(contentsOf bytes: Bytes)
    where Bytes: Collection, Bytes.Element == UInt8 {
        assert(bytes.count == SHAKE256.byteRate)
        for (i, chunk) in zip(indices, bytes.chunks(ofCount: 8)) {
            self[i] ^= UInt64(littleEndianBytes: chunk)!
        }
    }
    
    mutating func permute() {
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
            
            var a = self[0] ^ self[5] ^ self[10] ^ self[15] ^ self[20]
            var b = self[1] ^ self[6] ^ self[11] ^ self[16] ^ self[21]
            var c = self[2] ^ self[7] ^ self[12] ^ self[17] ^ self[22]
            var d = self[3] ^ self[8] ^ self[13] ^ self[18] ^ self[23]
            var e = self[4] ^ self[9] ^ self[14] ^ self[19] ^ self[24]
            
            var temp: UInt64
            
            temp = e ^ b.rotated(left: 1)
            self[ 0] ^= temp
            self[ 5] ^= temp
            self[10] ^= temp
            self[15] ^= temp
            self[20] ^= temp
            temp = a ^ c.rotated(left: 1)
            self[ 1] ^= temp
            self[ 6] ^= temp
            self[11] ^= temp
            self[16] ^= temp
            self[21] ^= temp
            temp = b ^ d.rotated(left: 1)
            self[ 2] ^= temp
            self[ 7] ^= temp
            self[12] ^= temp
            self[17] ^= temp
            self[22] ^= temp
            temp = c ^ e.rotated(left: 1)
            self[ 3] ^= temp
            self[ 8] ^= temp
            self[13] ^= temp
            self[18] ^= temp
            self[23] ^= temp
            temp = d ^ a.rotated(left: 1)
            self[ 4] ^= temp
            self[ 9] ^= temp
            self[14] ^= temp
            self[19] ^= temp
            self[24] ^= temp
            
            // Rho and pi:
            
            temp = self[1]
            a = self[10]
            self[10] = temp.rotated(left: 1)
            temp = a
            a = self[7]
            self[7] = temp.rotated(left: 3)
            temp = a
            a = self[11]
            self[11] = temp.rotated(left: 6)
            temp = a
            a = self[17]
            self[17] = temp.rotated(left: 10)
            temp = a
            a = self[18]
            self[18] = temp.rotated(left: 15)
            temp = a
            a = self[3]
            self[3] = temp.rotated(left: 21)
            temp = a
            a = self[5]
            self[5] = temp.rotated(left: 28)
            temp = a
            a = self[16]
            self[16] = temp.rotated(left: 36)
            temp = a
            a = self[8]
            self[8] = temp.rotated(left: 45)
            temp = a
            a = self[21]
            self[21] = temp.rotated(left: 55)
            temp = a
            a = self[24]
            self[24] = temp.rotated(left: 2)
            temp = a
            a = self[4]
            self[4] = temp.rotated(left: 14)
            temp = a
            a = self[15]
            self[15] = temp.rotated(left: 27)
            temp = a
            a = self[23]
            self[23] = temp.rotated(left: 41)
            temp = a
            a = self[19]
            self[19] = temp.rotated(left: 56)
            temp = a
            a = self[13]
            self[13] = temp.rotated(left: 8)
            temp = a
            a = self[12]
            self[12] = temp.rotated(left: 25)
            temp = a
            a = self[2]
            self[2] = temp.rotated(left: 43)
            temp = a
            a = self[20]
            self[20] = temp.rotated(left: 62)
            temp = a
            a = self[14]
            self[14] = temp.rotated(left: 18)
            temp = a
            a = self[22]
            self[22] = temp.rotated(left: 39)
            temp = a
            a = self[9]
            self[9] = temp.rotated(left: 61)
            temp = a
            a = self[6]
            self[6] = temp.rotated(left: 20)
            temp = a
            a = self[1]
            self[1] = temp.rotated(left: 44)
            
            // Chi:
            
            a = self[0]
            b = self[1]
            c = self[2]
            d = self[3]
            e = self[4]
            self[0] ^= ~b & c
            self[1] ^= ~c & d
            self[2] ^= ~d & e
            self[3] ^= ~e & a
            self[4] ^= ~a & b
            a = self[5]
            b = self[6]
            c = self[7]
            d = self[8]
            e = self[9]
            self[5] ^= ~b & c
            self[6] ^= ~c & d
            self[7] ^= ~d & e
            self[8] ^= ~e & a
            self[9] ^= ~a & b
            a = self[10]
            b = self[11]
            c = self[12]
            d = self[13]
            e = self[14]
            self[10] ^= ~b & c
            self[11] ^= ~c & d
            self[12] ^= ~d & e
            self[13] ^= ~e & a
            self[14] ^= ~a & b
            a = self[15]
            b = self[16]
            c = self[17]
            d = self[18]
            e = self[19]
            self[15] ^= ~b & c
            self[16] ^= ~c & d
            self[17] ^= ~d & e
            self[18] ^= ~e & a
            self[19] ^= ~a & b
            a = self[20]
            b = self[21]
            c = self[22]
            d = self[23]
            e = self[24]
            self[20] ^= ~b & c
            self[21] ^= ~c & d
            self[22] ^= ~d & e
            self[23] ^= ~e & a
            self[24] ^= ~a & b
            
            // Iota:
            
            self[0] ^= roundConstant
        }
    }
}

// TODO: Remove when availible in Numerics.
fileprivate extension UInt64 {
    @inline(__always)
    func rotated(left count: Int) -> Self {
        (self &<< count) | (self &>> (Self.bitWidth - count))
    }
}
