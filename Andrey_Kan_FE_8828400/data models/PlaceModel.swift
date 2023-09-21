// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let place = try? JSONDecoder().decode(Place.self, from: jsonData)

import Foundation

// MARK: - Place
struct Place: Codable {
    let predictions: [Prediction]
    let status: String
}

// MARK: - Prediction
struct Prediction: Codable {
    let description: String
    let matchedSubstrings: [MatchedSubstring]
    let placeID, reference: String
    let structuredFormatting: StructuredFormatting
    let terms: [Term]
    let types: [TypeElement]

    enum CodingKeys: String, CodingKey {
        case description
        case matchedSubstrings = "matched_substrings"
        case placeID = "place_id"
        case reference
        case structuredFormatting = "structured_formatting"
        case terms, types
    }
}

// MARK: - MatchedSubstring
struct MatchedSubstring: Codable {
    let length, offset: Int
}

// MARK: - StructuredFormatting
struct StructuredFormatting: Codable {
    let mainText: String
    let mainTextMatchedSubstrings: [MatchedSubstring]
    let secondaryText: String

    enum CodingKeys: String, CodingKey {
        case mainText = "main_text"
        case mainTextMatchedSubstrings = "main_text_matched_substrings"
        case secondaryText = "secondary_text"
    }
}

// MARK: - Term
struct Term: Codable {
    let offset: Int
    let value: String
}

enum TypeElement: String, Codable {
    case geocode = "geocode"
    case locality = "locality"
    case political = "political"
}

