//
//  SyllabusViewController.swift
//  crackItUp
//
//  Created by TANVI HARDE on 20/09/25.
//

import UIKit
import FirebaseFirestore

struct syllabus {
    let id: String
    let title: String
}

final class SyllabusViewController: UIViewController {
    let roundName: String
    let fieldId: String
    let fieldTitle: String

    private let db = Firestore.firestore()
    private var syllabi: [Syllabus] = []

    private let scrollView = UIScrollView()
    private let stackView = UIStackView()

    // Custom initializer
    init(roundName: String, fieldId: String, fieldTitle: String) {
        self.roundName = roundName
        self.fieldId = fieldId
        self.fieldTitle = fieldTitle
       
        super.init(nibName: nil, bundle: nil)
    }


    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupScrollView()
        setupStackView()
        fetchSyllabi()

        let backgroundImageView = UIImageView(frame: view.bounds)
        backgroundImageView.image = UIImage(named: "bgImage")
        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(backgroundImageView)
        view.sendSubviewToBack(backgroundImageView)
        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    private func setupScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func setupStackView() {
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }

    private func fetchSyllabi() {
        db.collection("rounds").document(roundName)
            .collection("fields").document(fieldId)
            .collection("syllabus")
            .getDocuments { snapshot, error in
                guard let documents = snapshot?.documents, error == nil else { return }
                self.syllabi = documents.map {
                    let title = $0.data()["title"] as? String ?? $0.documentID
                    return Syllabus(id: $0.documentID, title: title)
                }
                DispatchQueue.main.async { self.addSyllabusButtons() }
            }
    }

    private func addSyllabusButtons() {
        // Remove old buttons first!
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for (i, syllabus) in syllabi.enumerated() {
            let button = UIButton(type: .system)
            button.applyCrackItStyle(title: syllabus.title)
            button.heightAnchor.constraint(equalToConstant: 70).isActive = true
            button.tag = i
            button.addTarget(self, action: #selector(syllabusTapped(_:)), for: .touchUpInside)
            stackView.addArrangedSubview(button)
        }
    }

    @objc private func syllabusTapped(_ sender: UIButton) {
            let selectedSyllabus = syllabi[sender.tag]
            let chapterVC = ChapterViewController(
                roundName: roundName,
                fieldId: fieldId,
                fieldTitle: fieldTitle,
                syllabusId: selectedSyllabus.id,
                syllabusTitle: selectedSyllabus.title
            )
            navigationController?.pushViewController(chapterVC, animated: true)
        }
}


