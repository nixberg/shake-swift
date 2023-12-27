public struct TurboSHAKE128: ~Copyable {
    private var shake: SHAKE<Capacity128, KeccakP12>
    
    public init(domainSeparator: UInt8 = 0x1f) {
        shake = SHAKE(domainSeparator: domainSeparator)
    }
    
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

extension TurboSHAKE128 {
    public struct Output: IteratorProtocol, Sequence {
        fileprivate var output: SHAKE<Capacity128, KeccakP12>.Output.Iterator
        
        public mutating func next() -> UInt8? {
            output.next()
        }
    }
}

extension TurboSHAKE128 {
    public static func hash(
        contentsOf bytes: some Sequence<UInt8>,
        outputByteCount: Int = 32,
        domainSeparator: UInt8 = 0x1f
    ) -> PrefixSequence<Output> {
        var shake = Self(domainSeparator: domainSeparator)
        shake.append(contentsOf: bytes)
        return shake.squeezed().prefix(outputByteCount)
    }
}
