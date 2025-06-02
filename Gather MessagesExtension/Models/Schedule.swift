//
//  Schedule.swift
//  Gather
//
//  Created by Renaissance Carr on 6/1/25.
//

import Foundation
import SwiftUI

struct Schedule: Codable, Identifiable {
    var id: String
    var startDate: Date
    var endDate: Date
    var timeSlots: [String: [String: Bool]]
}
