//
//  Enums.swift
//  AutoCompleteTextIdeaFlow
//
//  Created by vishnu on 26/05/24.
//

import Foundation

enum AutocompleteType: String {
    case hashtag = "#"
    case atMention = "@"
    case relation = "<>"
}

struct AutocompleteData {
    let hashtags: [String]
    let mentions: [String]
    let relations: [String]
}



