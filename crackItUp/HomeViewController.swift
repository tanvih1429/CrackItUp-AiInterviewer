//
//  HomeViewController.swift
//  crackItUp
//
//  Created by TANVI HARDE on 21/09/25.
//

import UIKit
import FirebaseFirestore   // ✅ NEW (for Firestore later)
import FirebaseAuth        // ✅ NEW (for user progress later)

class HomeViewController: UIViewController {  // ✅ Added UIViewController inheritance
   
    @IBOutlet weak var continue_learning: UILabel!
    @IBOutlet weak var courses_Lable: UILabel!
   
    @IBOutlet weak var aptitude: UIButton!
    @IBOutlet weak var technical: UIButton!
    @IBOutlet weak var coding: UIButton!
    @IBOutlet weak var interview: UIButton!
   

   
   
   
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true
        // ✅ Example styling for buttons (optional)
        aptitude.setTitle("Aptitude", for: .normal)
        technical.setTitle("Training", for: .normal)
        coding.setTitle("Coding", for: .normal)
        interview.setTitle("Interview", for: .normal)
        let backgroundImageView = UIImageView(frame: view.bounds)
        backgroundImageView.image = UIImage(named: "register") // image in Assets
        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
       
        view.addSubview(backgroundImageView)
        view.sendSubviewToBack(backgroundImageView)
       
        // Auto Layout
        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        let feedbackButton = UIBarButtonItem(title: "Feedback", style: .plain, target: self, action: #selector(showFeedback))
            self.navigationItem.rightBarButtonItem = feedbackButton
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    // ✅ When aptitude button is tapped
    @IBAction func aptiButton(_ sender: Any) {
        let chapterVC = ChapterViewController(roundName: "aptitude") // ✅ use your custom init
        self.navigationController?.pushViewController(chapterVC, animated: true)
    }
    @IBAction func trainingButton(_ sender: Any) {
        let chapterVC = ChapterViewController(roundName: "training") // ✅ use your custom init
        self.navigationController?.pushViewController(chapterVC, animated: true)
    }
   
    @IBAction func codingButton(_ sender: Any)  {
        let fieldVC = FieldViewController()
        self.navigationController?.pushViewController(fieldVC, animated: true)
    }

    @objc private func showFeedback() {
        let feedbackVC = FeedBackViewController()
        self.navigationController?.pushViewController(feedbackVC, animated: true)
    }
}
