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
    
    // Example levels
    private let levels = (1...20).map { "Level \($0)" }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupScrollView()
        setupStackView()
        addLevelButtons()
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
        self.layer.shadowRadius = 6
    }
}
