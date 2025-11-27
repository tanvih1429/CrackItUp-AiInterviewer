//
//  FieldViewController.swift
//  crackItUp
//
//  Created by TANVI HARDE on 20/09/25.
//

import UIKit
import FirebaseFirestore

final class FieldViewController: UIViewController {
    let db = Firestore.firestore()
    private var fieldNames: [String] = []
    private var fieldTitles: [String: String] = [:] // To show readable field names

    private let scrollView = UIScrollView()
    private let stackView = UIStackView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupScrollView()
        setupStackView()
        fetchFields()
    }

    private func setupScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func setupStackView() {
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -20),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -40)
        ])
    }

    private func addFieldButtons() {
        // Remove old buttons
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for fieldId in fieldNames {
            let button = UIButton(type: .system)
            let title = fieldTitles[fieldId] ?? fieldId
            button.setTitle(title.capitalized, for: .normal)
            button.backgroundColor = UIColor(hex: "#613A14")
            button.setTitleColor(.white, for: .normal)
            button.layer.cornerRadius = 15
            button.layer.borderColor = UIColor(hex: "#F9E9D5").cgColor
            button.layer.borderWidth = 2
            button.heightAnchor.constraint(equalToConstant: 70).isActive = true
            button.tag = fieldNames.firstIndex(of: fieldId) ?? 0
            button.addTarget(self, action: #selector(fieldTapped(_:)), for: .touchUpInside)
            stackView.addArrangedSubview(button)
        }
    }

    // Fetch and display fields as buttons using their IDs and titles
    func fetchFields() {
        db.collection("rounds").document("coding").collection("fields").getDocuments { snapshot, error in
            guard let documents = snapshot?.documents, error == nil else { return }
            self.fieldNames = documents.map { $0.documentID }
            self.fieldTitles = Dictionary(uniqueKeysWithValues: documents.map { ($0.documentID, $0.data()["title"] as? String ?? $0.documentID) })
            DispatchQueue.main.async { self.addFieldButtons() }
        }
    }

    @objc private func fieldTapped(_ sender: UIButton) {
        let selectedFieldId = fieldNames[sender.tag]
        let selectedFieldTitle = fieldTitles[selectedFieldId] ?? selectedFieldId
        // Navigate to your syllabus selection controller for this field
        // For example:
        let syllabusVC = SyllabusViewController(roundName: "coding", fieldId: selectedFieldId, fieldTitle: selectedFieldTitle)
        navigationController?.pushViewController(syllabusVC, animated: true)
    }
}

