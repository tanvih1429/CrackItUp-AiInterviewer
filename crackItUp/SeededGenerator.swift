//
//  SeededGenerator.swift
//  crackItUp
//
//  Created by TANVI HARDE on 23/08/25.
//

import Foundation

/// A deterministic random number generator with a fixed seed.
/// Useful for reproducible shuffling (e.g. same MCQ order for the same seed).
struct SeededGenerator: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        // Avoid 0 because LCG with state = 0 stays at 0
        self.state = seed == 0 ? 0xdeadbeef : seed
    }

    mutating func next() -> UInt64 {
        // Linear Congruential Generator (LCG) parameters
        state = state &* 6364136223846793005 &+ 1
        return state
    }
}
