//
//  AutoCompleteView.swift
//  AutoCompleteTextIdeaFlow
//
//  Created by vishnu on 26/05/24.
//

import Foundation
import UIKit

class AutocompleteView: UIView {
    private var tableView: UITableView!
    private var options: [String] = []
    private var onSelectOption: ((String) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupTableView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupTableView() {
        tableView = UITableView(frame: bounds, style: .plain)
        tableView.dataSource = self
        tableView.delegate = self
        addSubview(tableView)
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.backgroundColor = UIColor.white
    }
    
    func updateOptions(options: [String]) {
        self.options = options
        tableView.reloadData()
    }
    
    func didSelectOption(completion: @escaping (String) -> Void) {
        self.onSelectOption = completion
    }
}

extension AutocompleteView: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = options[indexPath.row]
        if options[indexPath.row].contains("@") {
            cell.textLabel?.textColor = .green
        }
        if options[indexPath.row].contains("#") {
            cell.textLabel?.textColor = .blue
        }
        if options[indexPath.row].contains("<>") {
            cell.textLabel?.textColor = .orange
        }
        cell.backgroundColor = UIColor.white
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        onSelectOption?(options[indexPath.row])
    }
}

