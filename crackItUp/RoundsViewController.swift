//
//  RoundsViewController.swift
//  crackItUp
//
//  Created by TANVI HARDE on 24/08/25.
//

import UIKit

class RoundsViewController: UIViewController {
    private var rounds: [Round] = []
    private let tableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Rounds"
        view.backgroundColor = .systemBackground
        setupTableView()
        fetchRounds()
    }
    
    private func setupTableView() {
        tableView.frame = view.bounds
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "RoundCell")
        view.addSubview(tableView)
    }
    
    private func fetchRounds() {
        FirestoreService.shared.fetchRounds { [weak self] rounds in
            self?.rounds = rounds
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
    }
}

extension RoundsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { rounds.count }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RoundCell", for: indexPath)
        cell.textLabel?.text = rounds[indexPath.row].title
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let round = rounds[indexPath.row]
        
        if round.id == "coding" {
            let vc = FieldViewController()
            vc.roundId = round.id
            navigationController?.pushViewController(vc, animated: true)
        } else {
            let vc = ChapterViewController()
            vc.roundId = round.id
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}
