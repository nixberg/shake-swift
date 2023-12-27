public struct SHAKE128: ~Copyable {
    private var shake = SHAKE<Capacity128, KeccakP24>(domainSeparator: 0x1f)
    
    public init() {}
    
    public mutating func append(_ newElement: UInt8) {
        shake.append(newElement)
    }
    
    public mutating func append(contentsOf newElements: some Sequence<UInt8>) {
        shake.append(contentsOf: newElements)
    }
    
    public consuming func squeezed() -> Output {
        Output(output: (consume self).shake.squeezed().makeIterator())
    }
}

extension SHAKE128 {
    public struct Output: IteratorProtocol, Sequence {
        fileprivate var output: SHAKE<Capacity128, KeccakP24>.Output.Iterator
        
        public mutating func next() -> UInt8? {
            output.next()
        }
    }
}

extension SHAKE128 {
    public static func hash(
        contentsOf bytes: some Sequence<UInt8>,
        outputByteCount: Int = 32
    ) -> PrefixSequence<Output> {
        var shake = Self()
        shake.append(contentsOf: bytes)
        return shake.squeezed().prefix(outputByteCount)
    }
}
