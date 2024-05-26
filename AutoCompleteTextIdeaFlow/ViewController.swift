//
//  ViewController.swift
//  AutoCompleteTextIdeaFlow
//
//  Created by vishnu on 25/05/24.
//

import UIKit

class ViewController: UIViewController {
    private var autocompleteView: AutocompleteView!
    private var viewModel: AutocompleteViewModelProtocol!
    private var textView: UITextView = UITextView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.viewModel = AutocompleteViewModel()
        setupTextView()
        setupAutocompleteView()
    }
    
    func setupTextView() {
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.delegate = self
        textView.font = UIFont.systemFont(ofSize: 18)
        textView.layer.borderColor = UIColor.lightGray.cgColor
        textView.layer.borderWidth = 1.0
        textView.layer.cornerRadius = 8.0
        view.addSubview(textView)
        textView.autocapitalizationType = .none
        
        NSLayoutConstraint.activate([
            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            textView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            textView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            textView.heightAnchor.constraint(equalToConstant: 150)
        ])
    }
    
    private func setupAutocompleteView() {
        autocompleteView = AutocompleteView(frame: CGRect(x: 0, y: 300, width: view.bounds.width, height: 200))
        view.addSubview(autocompleteView)
        NSLayoutConstraint.activate([
            autocompleteView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            autocompleteView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            autocompleteView.topAnchor.constraint(equalTo: textView.bottomAnchor, constant: 10),
            autocompleteView.heightAnchor.constraint(equalToConstant: 200)
        ])
        
        autocompleteView.didSelectOption { [weak self] selectedOption in
            // Handle selected option
            guard let self else { return }
            print("Selected Option: \(selectedOption)")
            self.autocompleteView.isHidden = true
            self.viewModel.updateTextView(with: selectedOption, textView: self.textView)
        }
        
        // Display suggestions.
        viewModel.onAutocompleteOptionSelected = { [weak self] options in
            self?.autocompleteView.isHidden = !(options.count > 0)
            self?.autocompleteView.updateOptions(options: options)
        }
    }
    
    // Handle text input
    func handleTextInput(text: String) {
        if text.contains("#") {
            viewModel.startAutocomplete(type: .hashtag, matchString: extractMatchString(text: text, trigger: "#"))
        } else if text.contains("@") {
            viewModel.startAutocomplete(type: .atMention, matchString: extractMatchString(text: text, trigger: "@"))
        } else if text.contains("<>") {
            viewModel.startAutocomplete(type: .relation, matchString: extractMatchString(text: text, trigger: "<>"))
        } else {
            autocompleteView.isHidden = true
        }
    }
    
    func extractMatchString(text: String, trigger: String) -> String {
        guard let range = text.range(of: trigger) else { return "" }
        return String(text[range.lowerBound...])
    }
}

extension ViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        // Concatenate the current text with the replacement string to get the updated text
        let currentText = textView.text as NSString
        let newText = currentText.replacingCharacters(in: range, with: text)
        // Call handleTextInput with the updated text
        handleTextInput(text: newText)
        if !text.isEmpty {
            let defaultAttributes: [NSAttributedString.Key: Any] = [
                .foregroundColor: UIColor.black // Set your default color here
            ]
            
            let attributedText = NSMutableAttributedString(attributedString: textView.attributedText)
            let newAttributedText = NSAttributedString(string: text, attributes: defaultAttributes)
            
            attributedText.replaceCharacters(in: range, with: newAttributedText)
            textView.attributedText = attributedText
            textView.selectedRange = NSRange(location: range.location + text.count, length: 0)
            return false
        }
        
        return true
    }
}

