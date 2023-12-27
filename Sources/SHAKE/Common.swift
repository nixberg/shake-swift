import KeccakP

protocol CapacityProtocol {
    static var value: Int { get }
}

enum Capacity128: CapacityProtocol {
    static let value = 168
}

enum Capacity256: CapacityProtocol {
    static let value = 136
}

protocol PermutationProtocol {
    static func apply(to state: inout State)
}

enum KeccakP12: PermutationProtocol {
    static func apply(to state: inout State) {
        state.permute(rounds: 12)
    }
}

enum KeccakP24: PermutationProtocol {
    static func apply(to state: inout State) {
        state.permute(rounds: 24)
    }
}
