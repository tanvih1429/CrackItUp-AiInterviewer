//
//  MCQSession.swift
//  crackItUp
//
//  Created by TANVI HARDE on 23/08/25.
//

import Foundation

struct MCQSession {
    static func sample(mcqs: [Question], avoiding seen: [String], count: Int, seed: UInt64) -> [Question] {
        var rng = SeededGenerator(seed: seed)
        
        // Only include questions that have a valid id and are not in 'seen'
        let unseen = mcqs.filter { question in
            if let id = question.id {
                return !seen.contains(id)
            }
            return false
        }
        
        return Array(unseen.shuffled(using: &rng).prefix(count))
    }
}
