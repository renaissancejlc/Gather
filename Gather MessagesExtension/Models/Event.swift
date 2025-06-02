//
//  Event.swift
//  Gather
//
//  Created by Renaissance Carr on 6/1/25.
//

import Foundation
import UIKit

struct Event: Codable, Identifiable {
    var id: String
    var title: String
    var location: String
    var dateTime: String
    var details: String
    var imageData: Data? // Optional image data
    var reactions: [String: String]

    var uiImage: UIImage? {
        guard let data = imageData else { return nil }
        return UIImage(data: data)
    }
}
