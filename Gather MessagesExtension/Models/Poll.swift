//
//  Poll.swift
//  Gather
//
//  Created by Renaissance Carr on 6/1/25.
//

import Foundation

struct PollOption: Codable {
    var text: String
    var votes: Int
}

struct Poll: Codable {
    var question: String
    var options: [PollOption]
    var isMultiSelect: Bool
    var votedUserIDs: [String] = []

    mutating func vote(from userID: String, at index: Int) {
        guard !votedUserIDs.contains(userID), options.indices.contains(index) else { return }
        options[index].votes += 1
        votedUserIDs.append(userID)
    }

    func hasVoted(userID: String) -> Bool {
        return votedUserIDs.contains(userID)
    }
}
