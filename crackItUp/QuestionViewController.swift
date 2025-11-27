import UIKit
import FirebaseFirestore
import FirebaseAuth

struct Questions {
    let id: String
    let prompt: String
    let options: [String]
    let correctIndex: Int
}

struct UserAnswer {
    let questionId: String
    let selectedIndex: Int
    let isCorrect: Bool
}

class QuestionViewController: UIViewController {
    // MARK: - Properties
    private let roundName: String
    private let chapterName: String
    private let subtopicName: String
    private let fieldId: String?
    private let syllabusId: String?

    private let saveAndNextButton = UIButton(type: .system)
    private let navToggleButton = UIButton(type: .system)
    private let navOverlayView = UIView()
    private var navStackView = UIStackView()
    private var navQuestionButtons: [UIButton] = []

    private let db = Firestore.firestore()
    private var questions: [Questions] = []
    private var currentQuestionIndex = 0
    private var answered = false
    private var userAnswers: [UserAnswer] = []
    private var defaultColors: [UIColor] = []

    private let mcqLabel: UILabel = {
        let l = UILabel()
        l.text = "MCQ'S"
        l.font = .systemFont(ofSize: 27, weight: .heavy)
        l.textColor = UIColor(hex: "#613A14")
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    private let subtopicTitleLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 22, weight: .bold)
        l.textColor = UIColor(hex: "#613A14")
        l.textAlignment = .center
        l.numberOfLines = 2
        l.lineBreakMode = .byWordWrapping
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    private let promptLabel: UILabel = {
        let l = UILabel()
        l.font = UIFont.boldSystemFont(ofSize: 18)
        l.numberOfLines = 0
        l.textColor = UIColor(hex: "#F9E9D5")
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    private let optionOne = UIButton(type: .system)
    private let optionTwo = UIButton(type: .system)
    private let optionThree = UIButton(type: .system)
    private let optionFour = UIButton(type: .system)
    private lazy var optionButtons: [UIButton] = [optionOne, optionTwo, optionThree, optionFour]
    private let nextButton = UIButton(type: .system)

    // MARK: - Init
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    init(roundName: String, fieldId: String, syllabusId: String, chapterName: String, subtopicName: String) {
        self.roundName = roundName
        self.fieldId = fieldId
        self.syllabusId = syllabusId
        self.chapterName = chapterName
        self.subtopicName = subtopicName
        super.init(nibName: nil, bundle: nil)
    }
    init(roundName: String, chapterName: String, subtopicName: String) {
        self.roundName = roundName
        self.chapterName = chapterName
        self.subtopicName = subtopicName
        self.fieldId = nil
        self.syllabusId = nil
        super.init(nibName: nil, bundle: nil)
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        // --- CHAPTER AUTH CHECK ---
        if Auth.auth().currentUser == nil && (
                isChapter3OrLater(chapterName) ||
                isSubtopic3OrLater(subtopicName)
            ) {
                showLoginRequiredPopup()
                return
            }
        setupUI()
        fetchSubtopicTitle()
        fetchQuestions()

        let backgroundImageView = UIImageView(frame: view.bounds)
        backgroundImageView.image = UIImage(named: "register")
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
        self.title = ""
        navigationController?.setNavigationBarHidden(true, animated: false)
        navToggleButton.setImage(UIImage(systemName: "sidebar.leading"), for: .normal)
        navToggleButton.backgroundColor = UIColor.systemBrown
        navToggleButton.layer.cornerRadius = 24
        navToggleButton.tintColor = .white
        navToggleButton.translatesAutoresizingMaskIntoConstraints = false
        navToggleButton.addTarget(self, action: #selector(showNavOverlay), for: .touchUpInside)
        view.addSubview(navToggleButton)
        NSLayoutConstraint.activate([
            navToggleButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12),
            navToggleButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 50),
            navToggleButton.widthAnchor.constraint(equalToConstant: 48),
            navToggleButton.heightAnchor.constraint(equalToConstant: 48)
        ])
    }

    // MARK: - UI Setup
    private func setupUI() {
        view.addSubview(mcqLabel)
        view.addSubview(subtopicTitleLabel)
        view.addSubview(promptLabel)
        NSLayoutConstraint.activate([
            mcqLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            mcqLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            mcqLabel.heightAnchor.constraint(equalToConstant: 35),
            subtopicTitleLabel.topAnchor.constraint(equalTo: mcqLabel.bottomAnchor, constant: 8),
            subtopicTitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            subtopicTitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            promptLabel.topAnchor.constraint(equalTo: subtopicTitleLabel.bottomAnchor, constant: 160),
            promptLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            promptLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
        for (i, btn) in optionButtons.enumerated() {
            btn.tag = i  // CRITICAL: Option index as tag
            btn.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
            btn.setTitleColor(UIColor(hex: "#F9E9D5"), for: .normal)
            btn.backgroundColor = UIColor(hex: "#774818").withAlphaComponent(0.7)
            btn.layer.cornerRadius = 12
            btn.layer.borderColor = UIColor(hex: "#F9E9D5").cgColor
            btn.layer.borderWidth = 1
            btn.translatesAutoresizingMaskIntoConstraints = false
            btn.heightAnchor.constraint(equalToConstant: 90).isActive = true
            btn.addTarget(self, action: #selector(optionTapped(_:)), for: .touchUpInside)
            btn.titleLabel?.numberOfLines = 0
            btn.titleLabel?.lineBreakMode = .byWordWrapping
            btn.titleLabel?.textAlignment = .center
        }
        defaultColors = optionButtons.map { $0.backgroundColor ?? .clear }
        let topRow = UIStackView(arrangedSubviews: [optionOne, optionTwo])
        topRow.axis = .horizontal
        topRow.spacing = 20
        topRow.distribution = .fillEqually
        let bottomRow = UIStackView(arrangedSubviews: [optionThree, optionFour])
        bottomRow.axis = .horizontal
        bottomRow.spacing = 20
        bottomRow.distribution = .fillEqually
        let optionsStack = UIStackView(arrangedSubviews: [topRow, bottomRow])
        optionsStack.axis = .vertical
        optionsStack.spacing = 20
        optionsStack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(optionsStack)
        NSLayoutConstraint.activate([
            optionsStack.topAnchor.constraint(equalTo: promptLabel.bottomAnchor, constant: 32),
            optionsStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            optionsStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
        nextButton.setTitle("Next", for: .normal)
        nextButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        nextButton.backgroundColor = UIColor(hex: "#8B9CFF").withAlphaComponent(0.7)
        nextButton.layer.cornerRadius = 28
        nextButton.setTitleColor(.systemIndigo, for: .normal)
        nextButton.layer.borderColor = UIColor(hex: "#F9E9D5").cgColor
        nextButton.layer.borderWidth = 1
        nextButton.translatesAutoresizingMaskIntoConstraints = false
        nextButton.addTarget(self, action: #selector(nextTapped), for: .touchUpInside)
        view.addSubview(nextButton)
        saveAndNextButton.setTitle("Save & Next", for: .normal)
        saveAndNextButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        saveAndNextButton.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.7)
        saveAndNextButton.layer.cornerRadius = 28
        saveAndNextButton.setTitleColor(UIColor(hex: "#F9E9D5"), for: .normal)
        saveAndNextButton.layer.borderColor = UIColor(hex: "#F9E9D5").cgColor
        saveAndNextButton.layer.borderWidth = 1
        saveAndNextButton.translatesAutoresizingMaskIntoConstraints = false
        saveAndNextButton.addTarget(self, action: #selector(saveAndNextTapped), for: .touchUpInside)
        view.addSubview(saveAndNextButton)
        NSLayoutConstraint.activate([
            nextButton.topAnchor.constraint(equalTo: optionsStack.bottomAnchor, constant: 70),
            nextButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50),
            nextButton.widthAnchor.constraint(equalToConstant: 150),
            nextButton.heightAnchor.constraint(equalToConstant: 56),
            saveAndNextButton.topAnchor.constraint(equalTo: nextButton.topAnchor),
            saveAndNextButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -50),
            saveAndNextButton.widthAnchor.constraint(equalToConstant: 150),
            saveAndNextButton.heightAnchor.constraint(equalToConstant: 56),
        ])
        navOverlayView.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        navOverlayView.translatesAutoresizingMaskIntoConstraints = false
        navOverlayView.isHidden = true
        view.addSubview(navOverlayView)
        NSLayoutConstraint.activate([
            navOverlayView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            navOverlayView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            navOverlayView.topAnchor.constraint(equalTo: view.topAnchor),
            navOverlayView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        navStackView = UIStackView()
        navStackView.axis = .vertical
        navStackView.spacing = 16
        navStackView.alignment = .center
        navStackView.translatesAutoresizingMaskIntoConstraints = false
        navOverlayView.addSubview(navStackView)
        NSLayoutConstraint.activate([
            navStackView.trailingAnchor.constraint(equalTo: navOverlayView.trailingAnchor, constant: -24),
            navStackView.centerYAnchor.constraint(equalTo: navOverlayView.centerYAnchor)
        ])
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideNavOverlay))
        navOverlayView.addGestureRecognizer(tapGesture)
        let closeButton = UIButton(type: .system)
        closeButton.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        closeButton.tintColor = .white
        closeButton.backgroundColor = UIColor.systemGray
        closeButton.layer.cornerRadius = 16
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.addTarget(self, action: #selector(hideNavOverlay), for: .touchUpInside)
        navOverlayView.addSubview(closeButton)
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: navStackView.topAnchor, constant: -32),
            closeButton.trailingAnchor.constraint(equalTo: navStackView.trailingAnchor),
            closeButton.widthAnchor.constraint(equalToConstant: 32),
            closeButton.heightAnchor.constraint(equalToConstant: 32)
        ])
    }

    // MARK: - Overlay Nav Stack
    private func buildNavStack() {
        navQuestionButtons.forEach { $0.removeFromSuperview() }
        navQuestionButtons.removeAll()
        navStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        guard questions.count > 0 else { return }
        for (index, q) in questions.enumerated() {
            let btn = UIButton(type: .system)
            btn.tag = index
            btn.setTitle("\(index + 1)", for: .normal)
            btn.titleLabel?.font = .boldSystemFont(ofSize: 18)
            btn.setTitleColor(.white, for: .normal)
            btn.backgroundColor = navButtonColor(for: q.id)
            btn.layer.cornerRadius = 22
            btn.layer.masksToBounds = true
            btn.widthAnchor.constraint(equalToConstant: 44).isActive = true
            btn.heightAnchor.constraint(equalToConstant: 44).isActive = true
            btn.addTarget(self, action: #selector(navQuestionTapped(_:)), for: .touchUpInside)
            navStackView.addArrangedSubview(btn)
            navQuestionButtons.append(btn)
        }
    }
    private func navButtonColor(for questionId: String) -> UIColor {
        if let ua = userAnswers.first(where: { $0.questionId == questionId }) {
            if ua.selectedIndex == -1 {
                return UIColor.systemBlue
            } else {
                return UIColor.systemGreen
            }
        } else {
            return UIColor.systemGray2
        }
    }
    private func refreshNavButtonColors() {
        for (index, btn) in navQuestionButtons.enumerated() {
            btn.backgroundColor = navButtonColor(for: questions[index].id)
        }
    }
    @objc private func showNavOverlay() {
        buildNavStack()
        navOverlayView.isHidden = false
        view.bringSubviewToFront(navOverlayView)
    }
    @objc private func hideNavOverlay() {
        navOverlayView.isHidden = true
    }
    @objc private func navQuestionTapped(_ sender: UIButton) {
        hideNavOverlay()
        currentQuestionIndex = sender.tag
        showQuestion()
    }

    // MARK: - Firestore helpers
    private func fetchSubtopicTitle() {
        var ref: DocumentReference
        if roundName == "coding", let fieldId = fieldId, let syllabusId = syllabusId {
            ref = db.collection("rounds").document(roundName)
                .collection("fields").document(fieldId)
                .collection("syllabus").document(syllabusId)
                .collection("chapters").document(chapterName)
                .collection("subtopics").document(subtopicName)
        } else {
            ref = db.collection("rounds").document(roundName)
                .collection("chapters").document(chapterName)
                .collection("subtopics").document(subtopicName)
        }
        ref.getDocument { snapshot, error in
            if let data = snapshot?.data(), let title = data["title"] as? String {
                DispatchQueue.main.async { self.subtopicTitleLabel.text = title }
            } else {
                DispatchQueue.main.async { self.subtopicTitleLabel.text = self.subtopicName }
            }
        }
    }

    private func fetchQuestions() {
        var qRef: CollectionReference
        if roundName == "coding", let fieldId = fieldId, let syllabusId = syllabusId {
            qRef = db.collection("rounds").document(roundName)
                .collection("fields").document(fieldId)
                .collection("syllabus").document(syllabusId)
                .collection("chapters").document(chapterName)
                .collection("subtopics").document(subtopicName)
                .collection("questions")
        } else {
            qRef = db.collection("rounds").document(roundName)
                .collection("chapters").document(chapterName)
                .collection("subtopics").document(subtopicName)
                .collection("questions")
        }
        qRef.getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching questions:", error)
                return
            }
            guard let docs = snapshot?.documents else { return }
            self.questions = docs.compactMap { doc -> Questions? in
                let data = doc.data()
                guard let prompt = data["prompt"] as? String, let options = data["options"] as? [String] else {
                    return nil
                }
                let correctIndex: Int
                if let idx = data["correctIndex"] as? Int {
                    correctIndex = idx
                } else if let correctAnswer = data["correctAnswer"] as? String, let idx = options.firstIndex(of: correctAnswer) {
                    correctIndex = idx
                } else {
                    correctIndex = 0
                }
                return Questions(id: doc.documentID, prompt: prompt, options: options, correctIndex: correctIndex)
            }
            self.questions.shuffle()
            if self.questions.count > 8 {
                self.questions = Array(self.questions.prefix(8))
            }
            DispatchQueue.main.async {
                if !self.questions.isEmpty {
                    self.currentQuestionIndex = 0
                    self.showQuestion()
                } else {
                    self.promptLabel.text = "No questions available."
                }
            }
        }
    }

    // MARK: - Show / Reset question
    private func showQuestion() {
        answered = false
        nextButton.isEnabled = true
        nextButton.alpha = 1.0
        saveAndNextButton.isEnabled = false
        saveAndNextButton.alpha = 0.5
        let q = questions[currentQuestionIndex]
        promptLabel.text = "Q\(currentQuestionIndex + 1). \(q.prompt)"
        for (i, button) in optionButtons.enumerated() {
            if i < q.options.count {
                button.setTitle(q.options[i], for: .normal)
                button.isHidden = false
                button.isEnabled = true
                button.backgroundColor = i < defaultColors.count ? defaultColors[i] : UIColor(hex: "#774818").withAlphaComponent(0.7)
            } else {
                button.isHidden = true
            }
        }
        // Restore previous answer state if any
        if let userAnswer = userAnswers.first(where: { $0.questionId == questions[currentQuestionIndex].id }) {
            if userAnswer.selectedIndex != -1 {
                answered = true
                for (i, btn) in optionButtons.enumerated() {
                    btn.isEnabled = false
                    if i == userAnswer.selectedIndex {
                        let isCorrect = (i == questions[currentQuestionIndex].correctIndex)
                        btn.backgroundColor = isCorrect ? UIColor.systemGreen.withAlphaComponent(0.85) : UIColor.systemRed.withAlphaComponent(0.85)
                    }
                    if userAnswer.selectedIndex != questions[currentQuestionIndex].correctIndex && i == questions[currentQuestionIndex].correctIndex {
                        btn.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.85)
                    }
                }
                nextButton.isEnabled = true
                nextButton.alpha = 1.0
                saveAndNextButton.isEnabled = false
                saveAndNextButton.alpha = 0.5
            } else {
                answered = false
                optionButtons.forEach { $0.isEnabled = true }
            }
        }
        refreshNavButtonColors()
    }

    @objc private func optionTapped(_ sender: UIButton) {
        guard !answered else { return }
        answered = true
        saveAndNextButton.isEnabled = true
        saveAndNextButton.alpha = 1.0
        let selectedIndex = sender.tag
        let q = questions[currentQuestionIndex]
        let correctIndex = q.correctIndex
        let isCorrect = (selectedIndex == correctIndex)
        if let existingIndex = userAnswers.firstIndex(where: { $0.questionId == q.id }) {
            userAnswers[existingIndex] = UserAnswer(questionId: q.id, selectedIndex: selectedIndex, isCorrect: isCorrect)
        } else {
            userAnswers.append(UserAnswer(questionId: q.id, selectedIndex: selectedIndex, isCorrect: isCorrect))
        }
        if isCorrect {
            sender.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.85)
        } else {
            sender.backgroundColor = UIColor.systemRed.withAlphaComponent(0.85)
            if correctIndex >= 0 && correctIndex < optionButtons.count {
                let correctButton = optionButtons[correctIndex]
                correctButton.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.85)
            }
        }
        optionButtons.forEach { $0.isEnabled = false }
        nextButton.isEnabled = true
        nextButton.alpha = 1.0
        refreshNavButtonColors()
    }

    @objc private func nextTapped() {
        if !answered {
            let qid = questions[currentQuestionIndex].id
            if userAnswers.firstIndex(where: { $0.questionId == qid }) == nil {
                userAnswers.append(UserAnswer(questionId: qid, selectedIndex: -1, isCorrect: false))
            }
            answered = true
        }
        if currentQuestionIndex + 1 < questions.count {
            currentQuestionIndex += 1
            showQuestion()
        } else {
            saveProgress()
            let correct = userAnswers.filter { $0.isCorrect }.count
            let alert = UIAlertController(title: "Quiz Completed", message: "You answered \(correct) out of \(questions.count) correctly.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Review", style: .default) { _ in self.showReview() })
            present(alert, animated: true)
        }
    }

    @objc private func saveAndNextTapped() {
        if !answered {
            let qid = questions[currentQuestionIndex].id
            if userAnswers.firstIndex(where: { $0.questionId == qid }) == nil {
                userAnswers.append(UserAnswer(questionId: qid, selectedIndex: -1, isCorrect: false))
            }
            answered = true
        }
        if currentQuestionIndex + 1 < questions.count {
            currentQuestionIndex += 1
            showQuestion()
        } else {
            saveProgress()
            let correct = userAnswers.filter { $0.isCorrect }.count
            let alert = UIAlertController(title: "Quiz Completed", message: "You answered \(correct) out of \(questions.count) correctly.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Review", style: .default) { _ in self.showReview() })
            present(alert, animated: true)
        }
    }

    private func showReview() {
        let reviewVC = ProgressViewController(questions: self.questions, userAnswers: self.userAnswers)
        self.navigationController?.pushViewController(reviewVC, animated: true)
    }

    private func saveProgress() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let correct = userAnswers.filter { $0.isCorrect }.count
        let total = questions.count
        let percent = total == 0 ? 0 : Double(correct) / Double(total) * 100.0
        let progressKey = "\(chapterName)_\(subtopicName)"
        let docRef = db.collection("userProgress").document(uid)
            .collection("attempts")
            .document(progressKey)
        docRef.setData([
            "round": roundName,
            "chapter": chapterName,
            "subtopic": subtopicName,
            "correctAnswers": correct,
            "totalQuestions": total,
            "progressPercent": percent,
            "timestamp": FieldValue.serverTimestamp(),
            "answers": userAnswers.map {
                [
                    "questionId": $0.questionId,
                    "selectedIndex": $0.selectedIndex,
                    "isCorrect": $0.isCorrect
                ]
            }
        ], merge: true) { error in
            if let error = error {
                print("Error saving progress: \(error)")
            } else {
                print("Progress saved.")
            }
        }
    }

   

    private func showLoginRequiredPopup() {
            let alert = UIAlertController(
                title: "Login Required",
                message: "Please login to access this subtopic.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { [weak self] _ in
                self?.goBack()
            })
            alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
                self?.presentLoginScreen()
            })
            present(alert, animated: true)
        }

        private func presentLoginScreen() {
            // Get the main window's rootViewController (works with iOS 13+)
            let window: UIWindow? = {
                if #available(iOS 13.0, *) {
                    return UIApplication.shared.connectedScenes
                        .compactMap { $0 as? UIWindowScene }
                        .flatMap { $0.windows }
                        .first { $0.isKeyWindow }
                } else {
                    return UIApplication.shared.keyWindow
                }
            }()
            guard let rootVC = window?.rootViewController else {
                print("No rootViewController found"); return
            }

            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            guard let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as? UIViewController else {
                print("LoginViewController not found in storyboard")
                return
            }

            // Dismiss any presented modal first, then present login
            if let presented = rootVC.presentedViewController {
                presented.dismiss(animated: true) {
                    rootVC.present(loginVC, animated: true)
                }
            } else {
                rootVC.present(loginVC, animated: true)
            }
        }

        private func goBack() {
            if let nav = self.navigationController {
                nav.popViewController(animated: true)
            } else {
                self.dismiss(animated: true)
            }
        }

        // Helper: Lock logic for paid/premium chapters/subtopics
        private func isChapter3OrLater(_ chapterName: String) -> Bool {
            if let number = Int(chapterName.replacingOccurrences(of: "chapter", with: "").trimmingCharacters(in: .whitespaces)) {
                return number >= 3
            }
            return false
        }
        private func isSubtopic3OrLater(_ subtopicName: String) -> Bool {
            if let number = Int(subtopicName.replacingOccurrences(of: "subtopic", with: "").trimmingCharacters(in: .whitespaces)) {
                return number >= 3
            }
            return false
        }
    }

    // MARK: - UIColor convenience
    extension UIColor {
        convenience init(hex: String) {
            var cString: String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
            if cString.hasPrefix("#") { cString.remove(at: cString.startIndex) }
            var rgbValue: UInt64 = 0
            Scanner(string: cString).scanHexInt64(&rgbValue)
            self.init(
                red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
                green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
                blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
                alpha: CGFloat(1.0)
            )
        }
    }

