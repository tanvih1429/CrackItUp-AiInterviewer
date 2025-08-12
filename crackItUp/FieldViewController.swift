//
//  FieldViewController.swift
//  crackItUp
//
//  Created by TANVI HARDE on 14/08/25.
//

import UIKit

class FieldViewController: UIViewController, UISearchBarDelegate {
        
    @IBOutlet weak var searchBar: UISearchBar!
    private var fields: [Field] = []
        private let tableView = UITableView()
        var roundId: String = "coding" // by default for coding round
        
        override func viewDidLoad() {
            super.viewDidLoad()
            title = "Fields"
            view.backgroundColor = .systemBackground
            setupTableView()
            fetchFields()
        }
        
        private func setupTableView() {
            tableView.frame = view.bounds
            tableView.dataSource = self
            tableView.delegate = self
            tableView.register(UITableViewCell.self, forCellReuseIdentifier: "FieldCell")
            view.addSubview(tableView)
        }
        
        private func fetchFields() {
            FirestoreService.shared.fetchFields(roundId: roundId) { [weak self] fields in
                self?.fields = fields
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            }
        }
    }

    extension FieldViewController: UITableViewDataSource, UITableViewDelegate {
        
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            fields.count
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "FieldCell", for: indexPath)
            cell.textLabel?.text = fields[indexPath.row].title
            return cell
        }
        
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            let field = fields[indexPath.row]
            let syllabusVC = SyllabusViewController()
            syllabusVC.roundId = roundId
            syllabusVC.fieldId = field.id
            navigationController?.pushViewController(syllabusVC, animated: true)
        }
    }
