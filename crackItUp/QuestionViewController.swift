
//
//  QuestionViewController.swift
//  crackItUp
//
//  Created by TANVI HARDE on 20/09/25.
//

import UIKit
import FirebaseFirestore

struct Questions {
    let id: String
    let prompt: String
    let options: [String]
    let correctIndex: Int
}

class QuestionViewController: UIViewController {
    
    private let roundName: String
    private let chapterId: String
    private let subtopicId: String
    private let db = Firestore.firestore()
    
    private var questions: [Questions] = []
    private var currentIndex = 0
    
    private let mcqLabel = UILabel()
    private let subtopicLabel = UILabel()
    private let promptLabel = UILabel()
    private let optionButtons: [UIButton] = (0..<4).map { _ in UIButton(type: .system) }
    private let nextButton = UIButton(type: .system)
    
    init(roundName: String, chapterId: String, subtopicId: String) {
        self.roundName = roundName
        self.chapterId = chapterId
        self.subtopicId = subtopicId
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(hex: "#FFF5E1")
        setupViews()
        fetchQuestions()
    }
    
    private func setupViews() {
        // MCQ Label
        mcqLabel.text = "MCQ'S"
        mcqLabel.font = UIFont.systemFont(ofSize: 27, weight: .heavy)
        mcqLabel.textColor = UIColor(hex: "#613A14")
        mcqLabel.textAlignment = .center
        mcqLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mcqLabel)
        
        // Subtopic Label
        subtopicLabel.textColor = UIColor(hex: "#613A14")
        subtopicLabel.font = UIFont.systemFont(ofSize: 22, weight: .medium)
        subtopicLabel.textAlignment = .center
        subtopicLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(subtopicLabel)
        
        // Prompt
        promptLabel.numberOfLines = 0
        promptLabel.textColor = UIColor(hex: "#F9E9D5")
        promptLabel.backgroundColor = UIColor(hex: "#774818")
        promptLabel.textAlignment = .center
        promptLabel.layer.cornerRadius = 15
        promptLabel.clipsToBounds = true
        promptLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(promptLabel)
        
        // Option Buttons
        for button in optionButtons {
            button.backgroundColor = UIColor(hex: "#774818", alpha: 0.7)
            button.layer.borderColor = UIColor(hex: "#F9E9D5").cgColor
            button.layer.borderWidth = 1
            button.setTitleColor(UIColor(hex: "#F9E9D5"), for: .normal)
            button.layer.cornerRadius = 12
            button.addTarget(self, action: #selector(optionTapped(_:)), for: .touchUpInside)
            button.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(button)
        }
        
        // Next Button
        nextButton.setTitle("Next", for: .normal)
        nextButton.backgroundColor = UIColor(hex: "#8B9CFF", alpha: 0.7)
        nextButton.layer.cornerRadius = 28
        nextButton.layer.borderColor = UIColor.systemIndigo.cgColor
        nextButton.layer.borderWidth = 1
        nextButton.setTitleColor(.systemIndigo, for: .normal)
        nextButton.addTarget(self, action: #selector(nextTapped), for: .touchUpInside)
        nextButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nextButton)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            mcqLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            mcqLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            mcqLabel.heightAnchor.constraint(equalToConstant: 35),
            
            subtopicLabel.topAnchor.constraint(equalTo: mcqLabel.bottomAnchor, constant: 5),
            subtopicLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            subtopicLabel.heightAnchor.constraint(equalToConstant: 30),
            
            promptLabel.topAnchor.constraint(equalTo: subtopicLabel.bottomAnchor, constant: 20),
            promptLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            promptLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            promptLabel.heightAnchor.constraint(equalToConstant: 120)
        ])
        
        var previousButton: UIButton? = nil
        for button in optionButtons {
            NSLayoutConstraint.activate([
                button.heightAnchor.constraint(equalToConstant: 50),
                button.widthAnchor.constraint(equalToConstant: (view.frame.width - 60)/2)
            ])
            if let prev = previousButton {
                button.topAnchor.constraint(equalTo: prev.topAnchor).isActive = true
                button.leadingAnchor.constraint(equalTo: prev.trailingAnchor, constant: 20).isActive = true
            } else {
                button.topAnchor.constraint(equalTo: promptLabel.bottomAnchor, constant: 20).isActive = true
                button.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
            }
            previousButton = button
        }
        
        nextButton.topAnchor.constraint(equalTo: optionButtons.last!.bottomAnchor, constant: 30).isActive = true
        nextButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        nextButton.heightAnchor.constraint(equalToConstant: 56).isActive = true
        nextButton.widthAnchor.constraint(equalToConstant: 160).isActive = true
    }
    
    private func fetchQuestions() {
        db.collection("rounds").document(roundName)
          .collection("chapters").document(chapterId)
          .collection("subtopics").document(subtopicId)
          .collection("questions").getDocuments { snapshot, error in
            guard let documents = snapshot?.documents, error == nil else { return }
            self.questions = documents.map {
                Questions(
                    id: $0.documentID,
                    prompt: $0.data()["prompt"] as? String ?? "",
                    options: $0.data()["options"] as? [String] ?? [],
                    correctIndex: $0.data()["correctIndex"] as? Int ?? 0
                )
            }
            DispatchQueue.main.async { self.showQuestion() }
        }
    }
    
    private func showQuestion() {
        guard currentIndex < questions.count else { return }
        let q = questions[currentIndex]
        subtopicLabel.text = subtopicId
        promptLabel.text = q.prompt
        for (i, button) in optionButtons.enumerated() {
            if i < q.options.count { button.setTitle(q.options[i], for: .normal) }
        }
    }
    
    @objc private func optionTapped(_ sender: UIButton) {
        // Handle selection if needed
    }
    
    @objc private func nextTapped() {
        currentIndex += 1
        if currentIndex < questions.count { showQuestion() }
    }

}
