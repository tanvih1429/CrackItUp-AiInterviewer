//
//  MCQViewController.swift
//  CrackItUp
//
//  Created by Tanvi Harde on 24/08/25.
//

import UIKit
import FirebaseFirestore

class MCQViewController: UIViewController {
    
    // MARK: - Properties
    var roundId: String!
    var chapterId: String?
    var subtopicId: String?
    var fieldId: String?
    var syllabusId: String?
    
    private var mcqs: [MCQ] = []
    private var currentIndex = 0
    
    // MARK: - UI Elements
    private let questionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        label.textColor = .black
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    private var optionButtons: [UIButton] = []
    
    private let nextButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Next", for: .normal)
        btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        btn.isHidden = true
        return btn
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "MCQs"
        
        setupUI()
        fetchQuestions()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.addSubview(questionLabel)
        questionLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            questionLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            questionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            questionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
        
        // Option buttons
        for i in 0..<4 {
            let btn = UIButton(type: .system)
            btn.tag = i
            btn.titleLabel?.font = UIFont.systemFont(ofSize: 18)
            btn.layer.cornerRadius = 8
            btn.layer.borderWidth = 1
            btn.layer.borderColor = UIColor.gray.cgColor
            btn.backgroundColor = .systemGray6
            btn.addTarget(self, action: #selector(optionTapped(_:)), for: .touchUpInside)
            optionButtons.append(btn)
            view.addSubview(btn)
            btn.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                btn.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
                btn.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
                btn.heightAnchor.constraint(equalToConstant: 50)
            ])
            
            if i == 0 {
                btn.topAnchor.constraint(equalTo: questionLabel.bottomAnchor, constant: 30).isActive = true
            } else {
                btn.topAnchor.constraint(equalTo: optionButtons[i-1].bottomAnchor, constant: 20).isActive = true
            }
        }
        
        // Next Button
        view.addSubview(nextButton)
        nextButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            nextButton.topAnchor.constraint(equalTo: optionButtons.last!.bottomAnchor, constant: 40),
            nextButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        nextButton.addTarget(self, action: #selector(nextQuestion), for: .touchUpInside)
    }
    
    
    private func fetchQuestions() {
        let db = Firestore.firestore()
        let path = "rounds/\(roundId!)/chapters/\(chapterId ?? "")/subtopics/\(subtopicId ?? "")/questions"
        
        db.collection(path).limit(to: 10).getDocuments { [weak self] snapshot, error in
            if let error = error {
                print("❌ Error fetching questions: \(error)")
                return
            }
            
            guard let documents = snapshot?.documents else { return }
            
            self?.mcqs = documents.compactMap { doc -> MCQ? in
                let data = doc.data()
                guard
                    let question = data["question"] as? String,
                    let options = data["options"] as? [String],
                    let correctIndex = data["correctIndex"] as? Int
                else { return nil }
                
                return MCQ(id: doc.documentID, prompt: question, options: options, correctIndex: correctIndex)
            }
            
            DispatchQueue.main.async {
                self?.showQuestion()
            }
        }
    }



    
    // MARK: - Question Handling
    private func showQuestion() {
        guard currentIndex < mcqs.count else {
            questionLabel.text = "🎉 You completed all questions!"
            optionButtons.forEach { $0.isHidden = true }
            nextButton.isHidden = true
            return
        }
        
        let q = mcqs[currentIndex]
        questionLabel.text = "Q\(currentIndex+1). \(q.prompt)"
        
        for (i, btn) in optionButtons.enumerated() {
            btn.setTitle(q.options[i], for: .normal)
            btn.backgroundColor = .systemGray6
            btn.isEnabled = true
        }
        nextButton.isHidden = true
    }
    
    @objc private func optionTapped(_ sender: UIButton) {
        let q = mcqs[currentIndex]
        
        for btn in optionButtons {
            btn.isEnabled = false
        }
        
        if sender.tag == q.correctIndex {
            sender.backgroundColor = .systemGreen
        } else {
            sender.backgroundColor = .systemRed
            optionButtons[q.correctIndex].backgroundColor = .systemGreen
        }
        
        nextButton.isHidden = false
    }
    
    @objc private func nextQuestion() {
        currentIndex += 1
        showQuestion()
    }
}
