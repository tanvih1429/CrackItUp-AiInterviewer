
//
//  SyllabusViewController.swift
//  crackItUp
//
//  Created by TANVI HARDE on 20/09/25.
//


import UIKit

final class SyllabusViewController: UIViewController {
    private let scrollView = UIScrollView()
    private let stackView = UIStackView()
    private var syllabus: [Syllabus] = []   // ✅ syllabus instead of chapters

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupUI()
        loadSyllabus()
    }

    private func setupUI() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])

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
    
    private func addLevelButtons() {
        for level in levels {
            let button = UIButton(type: .system)
            button.applyCrackItStyle(title: level) // ✅ Apply custom style
            button.heightAnchor.constraint(equalToConstant: 80).isActive = true
            
            button.addTarget(self, action: #selector(levelTapped(_:)), for: .touchUpInside)
            stackView.addArrangedSubview(button)
        }
    }
    
    @objc private func levelTapped(_ sender: UIButton) {
        if let title = sender.titleLabel?.text {
            print("\(title) tapped")
        }
    }
}
extension UIButton {
    func applyCrackItStyle(title: String) {
        var config = UIButton.Configuration.filled()
        config.title = title
        config.baseBackgroundColor = UIColor(red: 60/255, green: 36/255, blue: 12/255, alpha: 1.0) // #3C240C
        config.baseForegroundColor = UIColor(red: 241/255, green: 216/255, blue: 204/255, alpha: 1.0) // #F1D8CC
        config.cornerStyle = .large
        config.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16)

        self.configuration = config
        self.layer.borderColor = UIColor(red: 241/255, green: 216/255, blue: 204/255, alpha: 1.0).cgColor // same as text color
               self.layer.borderWidth = 2
               self.layer.cornerRadius = 12
        // 🔹 Shadow styling
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.4
        self.layer.shadowOffset = CGSize(width: 2, height: 4)


    }

    private func loadSyllabus() {
        FirestoreService.shared.fetchSyllabus { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let items):
                    self?.syllabus = items
                    self?.renderButtons()
                case .failure(let err):
                    print("Syllabus error:", err.localizedDescription)
                }
            }
        }
    }

    private func renderButtons() {
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        for (idx, item) in syllabus.enumerated() {
            let button = UIButton(type: .system)
            button.setTitle(item.title, for: .normal)   // ✅ syllabus title
            button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
            button.setTitleColor(.white, for: .normal)
            button.applyCrackItStyle()
            button.heightAnchor.constraint(equalToConstant: 100).isActive = true
            button.tag = idx
            button.addTarget(self, action: #selector(syllabusTapped(_:)), for: .touchUpInside)
            stackView.addArrangedSubview(button)
        }
    }

    @objc private func syllabusTapped(_ sender: UIButton) {
        let item = syllabus[sender.tag]   // syllabus = [Syllabus]
        let vc = ChapterViewController(
            syllabusId: item.id,          // pass syllabus id
            syllabusTitle: item.title     // pass syllabus title
        )
        navigationController?.pushViewController(vc, animated: true)
    }
}


extension UIButton {
    func applyCrackItStyle() {
        // Rounded corners
        self.layer.cornerRadius = 16
        self.clipsToBounds = true

        // Background gradient
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor.systemPurple.cgColor,
            UIColor.systemBlue.cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        gradientLayer.frame = self.bounds
        gradientLayer.cornerRadius = 16

        // Remove old gradient if any
        if let old = (self.layer.sublayers?.first { $0 is CAGradientLayer }) {
            old.removeFromSuperlayer()
        }
        self.layer.insertSublayer(gradientLayer, at: 0)

        // Text style
        self.setTitleColor(.white, for: .normal)
        self.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)

        // Shadow for depth
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.25
        self.layer.shadowOffset = CGSize(width: 0, height: 4)

        self.layer.shadowRadius = 6
    }
}
