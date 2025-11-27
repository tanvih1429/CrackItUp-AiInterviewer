//
//  SubtopicViewController.swift
//  crackItUp
//
//  Created by TANVI HARDE on 20/09/25.
//
import UIKit
import FirebaseFirestore

struct Subtopics {
    let id: String
    let title: String
}

class SubtopicViewController: UIViewController {

    let roundName: String
    let chapterId: String
    let chapterTitle: String
    let fieldId: String?
    let syllabusId: String?

    private let db = Firestore.firestore()
    private var subtopics: [Subtopics] = []

    let scrollView = UIScrollView()
    let stackView = UIStackView()
    let titleLabel = UILabel()

    init(roundName: String, chapterId: String, chapterTitle: String) {
            self.roundName = roundName
            self.chapterId = chapterId
            self.chapterTitle = chapterTitle
            self.fieldId = nil
            self.syllabusId = nil
            super.init(nibName: nil, bundle: nil)
        }
    init(roundName: String, fieldId: String, syllabusId: String, chapterId: String, chapterTitle: String) {
            self.roundName = roundName
            self.fieldId = fieldId
            self.syllabusId = syllabusId
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
            setupTitleLabel()
            fetchSubtopics()
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
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 60),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -20),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -40)
        ])
    }

    private func setupTitleLabel() {
        titleLabel.text = chapterTitle
        titleLabel.textAlignment = .center
        titleLabel.font = .boldSystemFont(ofSize: 24)
        titleLabel.textColor = UIColor(hex: "#F9E9D5")
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    private func fetchSubtopics() {
            var collection: CollectionReference
            if roundName == "coding", let fieldId = fieldId, let syllabusId = syllabusId {
                collection = db.collection("rounds").document(roundName)
                    .collection("fields").document(fieldId)
                    .collection("syllabus").document(syllabusId)
                    .collection("chapters").document(chapterId)
                    .collection("subtopics")
            } else {
                collection = db.collection("rounds").document(roundName)
                    .collection("chapters").document(chapterId)
                    .collection("subtopics")
            }

            collection.getDocuments { snapshot, error in
                guard let documents = snapshot?.documents, error == nil else {
                    print("Error fetching subtopics: \(error?.localizedDescription ?? "")")
                    return
                }

                self.subtopics = documents.map { doc in
                    let data = doc.data()
                    let title = data["title"] as? String ?? doc.documentID
                    return Subtopics(id: doc.documentID, title: title)
                }

                DispatchQueue.main.async { self.addSubtopicButtons() }
            }
        }

    private func addSubtopicButtons() {
            for (index, subtopic) in subtopics.enumerated() {
                let button = UIButton(type: .system)
                button.setTitle(subtopic.title, for: .normal)
                button.backgroundColor = UIColor(hex: "#613A14")
                button.setTitleColor(.white, for: .normal)
                button.layer.cornerRadius = 15
                button.layer.borderColor = UIColor(hex: "#F9E9D5").cgColor
                button.layer.borderWidth = 1
                button.translatesAutoresizingMaskIntoConstraints = false
                button.heightAnchor.constraint(equalToConstant: 70).isActive = true
                button.widthAnchor.constraint(greaterThanOrEqualToConstant: 100).isActive = true
                button.tag = index
                button.addTarget(self, action: #selector(openQuestions(_:)), for: .touchUpInside)
                switch index % 3 {
                case 1: button.transform = CGAffineTransform(translationX: -20, y: 0)
                case 2: button.transform = CGAffineTransform(translationX: 20, y: 0)
                default: button.transform = .identity
                }
                stackView.addArrangedSubview(button)
            }
        }


    @objc private func openQuestions(_ sender: UIButton) {
            let selectedSubtopic = subtopics[sender.tag]
            let questionVC: QuestionViewController

            if roundName == "coding", let fieldId = fieldId, let syllabusId = syllabusId {
                questionVC = QuestionViewController(
                    roundName: roundName,
                    fieldId: fieldId,
                    syllabusId: syllabusId,
                    chapterName: chapterId,
                    subtopicName: selectedSubtopic.id
                )
            } else {
                questionVC = QuestionViewController(
                    roundName: roundName,
                    chapterName: chapterId,
                    subtopicName: selectedSubtopic.id
                )
            }
            questionVC.title = selectedSubtopic.title
            questionVC.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(questionVC, animated: true)
        }
}

