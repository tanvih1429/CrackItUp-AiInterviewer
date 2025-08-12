//
//  ChapterViewController.swift
//  crackItUp
//
//  Created by TANVI HARDE on 20/09/25.
//



// ✅ HEX Color Extension
import UIKit

// ✅ HEX Color Extension
extension UIColor {
    convenience init(hex: String, alpha: CGFloat = 1.0) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if hexSanitized.hasPrefix("#") { hexSanitized.remove(at: hexSanitized.startIndex) }
        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)
        let r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let b = CGFloat(rgb & 0x0000FF) / 255.0
        self.init(red: r, green: g, blue: b, alpha: alpha)
    }
}

// ✅ Custom button with progress and level
class ProgressButton: UIButton {
    
    private let progressLayer = CALayer()
    private let levelLabel = UILabel()
    private let percentLabel = UILabel()
    
    var progress: CGFloat = 0.0 { didSet { updateProgress() } }
    var levelText: String = "" { didSet { levelLabel.text = levelText } }
    var percentText: String = "" { didSet { percentLabel.text = percentText } }
    
    override init(frame: CGRect) { super.init(frame: frame); setupView() }
    required init?(coder: NSCoder) { super.init(coder: coder); setupView() }
    
    private func setupView() {
        layer.cornerRadius = 25
        clipsToBounds = true
        backgroundColor = UIColor(hex: "#F1C7A0") // beige
        
        progressLayer.backgroundColor = UIColor(hex: "#3C240C").cgColor // brown
        layer.insertSublayer(progressLayer, at: 0)
        
        levelLabel.textAlignment = .center
        levelLabel.textColor = .white
        levelLabel.font = UIFont.boldSystemFont(ofSize: 16)
        addSubview(levelLabel)
        
        percentLabel.textAlignment = .right
        percentLabel.textColor = .white
        percentLabel.font = UIFont.systemFont(ofSize: 14)
        addSubview(percentLabel)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        progressLayer.frame = CGRect(x: 0, y: 0, width: bounds.width * progress, height: bounds.height)
        levelLabel.frame = bounds
        percentLabel.frame = CGRect(x: bounds.width - 60, y: 0, width: 55, height: bounds.height)
    }
    
    private func updateProgress() {
        progressLayer.frame = CGRect(x: 0, y: 0, width: bounds.width * progress, height: bounds.height)
        percentText = "\(Int(progress * 100))%"
    }
}


import UIKit
import FirebaseFirestore

class ChapterViewController: UIViewController {
    
    var roundName: String
    private let db = Firestore.firestore()
    private var chapters: [(id: String, title: String)] = []
    
    let scrollView = UIScrollView()
    let stackView = UIStackView()
    
    init(roundName: String) {
        self.roundName = roundName
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupScrollView()
        setupStackView()
        fetchChapters()
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
    
    private func fetchChapters() {
        db.collection("rounds").document(roundName).collection("chapters").getDocuments { snapshot, error in
            guard let documents = snapshot?.documents, error == nil else { return }
            self.chapters = documents.map { (id: $0.documentID, title: $0.data()["title"] as? String ?? $0.documentID) }
            DispatchQueue.main.async { self.addChapterButtons() }
        }
    }
    
    private func addChapterButtons() {
        for (index, chapter) in chapters.enumerated() {
            let button = ProgressButton()
            button.levelText = chapter.title
            button.progress = 0.0
            button.tag = index
            button.translatesAutoresizingMaskIntoConstraints = false
            button.heightAnchor.constraint(equalToConstant: 50).isActive = true
            button.addTarget(self, action: #selector(openSubtopics(_:)), for: .touchUpInside)
            stackView.addArrangedSubview(button)
        }
    }
    
    @objc private func openSubtopics(_ sender: UIButton) {
        let chapter = chapters[sender.tag]
        let subtopicVC = SubtopicViewController(roundName: roundName, chapterId: chapter.id, chapterTitle: chapter.title)
        navigationController?.pushViewController(subtopicVC, animated: true)
    }
}
