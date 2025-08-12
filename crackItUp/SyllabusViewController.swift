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
            stackView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -20),
            stackView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -32)
        ])
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
