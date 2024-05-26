//
//  AutocompleteViewModel.swift
//  AutoCompleteTextIdeaFlow
//
//  Created by vishnu on 26/05/24.
//

import Foundation
import UIKit

protocol AutocompleteViewModelProtocol {
    var autocompleteData: AutocompleteData { get }
    var onAutocompleteOptionSelected: (([String]) -> Void)? { get set }
    
    func startAutocomplete(type: AutocompleteType, matchString: String)
    func updateTextView(with text: String, textView: UITextView)
}

class AutocompleteViewModel: AutocompleteViewModelProtocol {
    var autocompleteData: AutocompleteData
    var onAutocompleteOptionSelected: (([String]) -> Void)?
    let hashtagData = ["#Idea Flow", "#tech", "#coding", "#design", "#startup"]
    let mentionData = ["@Vishnu","@Jacob Cole", "@Jane Doe", "@John Smith", "@Emily Johnson", "@Alex Brown"]
    let relationData = ["Elon Musk <> Tesla Motors", "Steve Jobs <> Apple Inc.", "Mark Zuckerberg <> Facebook"]
    
    init() {
        self.autocompleteData = AutocompleteData(hashtags: hashtagData, mentions: mentionData, relations: relationData)
    }
    
    func startAutocomplete(type: AutocompleteType, matchString: String) {
        var options: [String] = []
        switch type {
        case .hashtag:
            options = autocompleteData.hashtags.filter { $0.lowercased().contains(matchString.lowercased()) }
        case .atMention:
            options = autocompleteData.mentions.filter { $0.lowercased().contains(matchString.last?.lowercased() ?? "") }
        case .relation:
            options = autocompleteData.relations.filter { $0.lowercased().contains(matchString.lowercased()) }
        }
        onAutocompleteOptionSelected?(options)
    }
    
    func updateTextView(with text: String, textView: UITextView) {
        guard let oldText = textView.text,
              let cursorPosition = textView.selectedRange.location as? Int,
              let char = text.first,
              let index = text.contains("<>") ? oldText.lastIndex(of: ">") : oldText.lastIndex(of: char) else {
            return
        }
        
        // Prepare the new text to replace part of the old text
        var newText = oldText
        newText.replaceSubrange(index..., with: text)
        
        let newCursorPosition = cursorPosition + text.count
        
        // Preserve existing attributed string
        let attributedString = NSMutableAttributedString(attributedString: textView.attributedText)
        
        // Update the part of the text with new content
        attributedString.replaceCharacters(in: NSRange(index..., in: oldText), with: text)
        
        // Define colors for different text types
        let hashtagColor = UIColor.blue
        let mentionColor = UIColor.green
        let relationColor = UIColor.orange
        
        // Add color attributes to the new text
        let nsNewText = newText as NSString
        if text.contains("#") {
            let range = nsNewText.range(of: text)
            attributedString.addAttribute(.foregroundColor, value: hashtagColor, range: range)
        }
        
        if text.contains("@") {
            let range = nsNewText.range(of: text)
            attributedString.addAttribute(.foregroundColor, value: mentionColor, range: range)
        }
        
        if text.contains("<>") {
            let range = nsNewText.range(of: text)
            attributedString.addAttribute(.foregroundColor, value: relationColor, range: range)
        }
        
        // Replace special characters with empty strings
        let specialCharacters = ["@", "#", "<>", "<", ">"]
        for character in specialCharacters {
            let fullRange = NSRange(location: 0, length: attributedString.length)
            attributedString.mutableString.replaceOccurrences(of: character, with: "", options: [], range: fullRange)
        }
        
        // Set the updated attributed string and cursor position
        textView.attributedText = attributedString
        textView.selectedRange = NSRange(location: newCursorPosition, length: 0)
    }
}
