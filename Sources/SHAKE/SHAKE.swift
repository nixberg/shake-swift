import KeccakP

struct SHAKE<Capacity: CapacityProtocol, Permutation: PermutationProtocol>: ~Copyable {
    private var state = State()
    private var index = 0
    
    private let domainSeparator: UInt8
    
    init(domainSeparator: UInt8) {
        precondition((0x01...0x7f).contains(domainSeparator))
        self.domainSeparator = domainSeparator
    }
    
    mutating func append(_ newElement: UInt8) {
        assert((0..<Capacity.value).contains(index))
        
        state.withUnsafeMutableBufferPointer {
            $0[index] ^= newElement
        }
        index += 1
        
        if index == Capacity.value {
            Permutation.apply(to: &state)
            index = 0
        }
    }
    
    mutating func append(contentsOf newElements: some Sequence<UInt8>) {
        for newElement in newElements {
            self.append(newElement)
        }
    }
    
    consuming func squeezed() -> Output {
        assert((0..<Capacity.value).contains(index))
        self.finalize()
        return Output(state: state)
    }
    
    // Workaround for "Overlapping accesses to 'self'" issue.
    private mutating func finalize() {
        state.withUnsafeMutableBufferPointer {
            $0[index] ^= domainSeparator
            $0[Capacity.value - 1] ^= 0x80
        }
    }
}

extension SHAKE {
    public struct Output: IteratorProtocol, Sequence {
        private var state: State
        private var index = Capacity.value
        
        fileprivate init(state: State) {
            self.state = state
        }
        
        public mutating func next() -> UInt8? {
            assert((0...Capacity.value).contains(index))
            
            if index == Capacity.value {
                Permutation.apply(to: &state)
                index = 0
            }
            
            defer { index += 1 }
            return state.withUnsafeBufferPointer {
                $0[index]
            }
        }
    }
}
