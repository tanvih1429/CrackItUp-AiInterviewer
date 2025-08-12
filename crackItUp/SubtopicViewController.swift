//
//  SubtopicViewController.swift
//  crackItUp
//
//  Created by TANVI HARDE on 20/09/25.
//
import UIKit
import FirebaseFirestore

class SubtopicViewController: UIViewController {
    
    private let roundName: String
    private let chapterId: String
    private let chapterTitle: String
    private let db = Firestore.firestore()
    private var subtopics: [(id: String, title: String)] = []
    
    let scrollView = UIScrollView()
    let stackView = UIStackView()
    
    init(roundName: String, chapterId: String, chapterTitle: String) {
        self.roundName = roundName
        self.chapterId = chapterId
        self.chapterTitle = chapterTitle
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupScrollView()
        setupStackView()
        fetchSubtopics()
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
        stackView.spacing = 40
        stackView.alignment = .center
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
    
    private func fetchSubtopics() {
        db.collection("rounds").document(roundName)
          .collection("chapters").document(chapterId)
          .collection("subtopics").getDocuments { snapshot, error in
            guard let documents = snapshot?.documents, error == nil else { return }
            self.subtopics = documents.map { (id: $0.documentID, title: $0.data()["title"] as? String ?? $0.documentID) }
            DispatchQueue.main.async { self.addSubtopicButtons() }
        }
    }
    
    private func addSubtopicButtons() {
        for (index, subtopic) in subtopics.enumerated() {
            let button = UIButton(type: .system)
            button.setTitle(subtopic.title, for: .normal)
            button.backgroundColor = .brown
            button.setTitleColor(.white, for: .normal)
            button.layer.cornerRadius = 15
            button.translatesAutoresizingMaskIntoConstraints = false
            button.heightAnchor.constraint(equalToConstant: 60).isActive = true
            button.widthAnchor.constraint(equalToConstant: 200).isActive = true
            button.tag = index
            button.addTarget(self, action: #selector(openQuestions(_:)), for: .touchUpInside)
            
            // Zigzag
            switch index % 3 {
            case 1: button.transform = CGAffineTransform(translationX: -80, y: 0)
            case 2: button.transform = CGAffineTransform(translationX: 80, y: 0)
            default: button.transform = .identity
            }
            
            stackView.addArrangedSubview(button)
        }
    }
    
    @objc private func openQuestions(_ sender: UIButton) {
        let subtopic = subtopics[sender.tag]
        let questionVC = QuestionViewController(roundName: roundName, chapterId: chapterId, subtopicId: subtopic.id)
        navigationController?.pushViewController(questionVC, animated: true)
    }
}
