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
    
    @IBOutlet weak var profile_image: UIImageView!
    @IBOutlet weak var name_Lable: UILabel!
    @IBOutlet weak var continue_learning: UILabel!
    @IBOutlet weak var courses_Lable: UILabel!
    
    @IBOutlet weak var aptitude: UIButton!
    @IBOutlet weak var technical: UIButton!
    @IBOutlet weak var coding: UIButton!
    @IBOutlet weak var interview: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // ✅ Example styling for buttons (optional)
        aptitude.setTitle("Aptitude", for: .normal)
        technical.setTitle("Training", for: .normal)
        coding.setTitle("Coding", for: .normal)
        interview.setTitle("Interview", for: .normal)
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



}
