import UIKit

class QuestionViewController: UIViewController {
    var roundId: String = ""
    var chapterId: String? = nil
    var subtopicId: String? = nil
    
    private var questions: [Question] = []
    private let tableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Questions"
        view.backgroundColor = .systemBackground
        setupTableView()
        fetchQuestions()
    }
    
    private func setupTableView() {
        tableView.frame = view.bounds
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "QuestionCell")
        view.addSubview(tableView)
    }
    
    private func fetchQuestions() {
        FirestoreService.shared.fetchQuestions(roundId: roundId, chapterId: chapterId, subtopicId: subtopicId) { [weak self] qs in
            self?.questions = qs
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
    }
}

extension QuestionViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { questions.count }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "QuestionCell", for: indexPath)
        let question = questions[indexPath.row]
        cell.textLabel?.text = question.prompt
        return cell
    }
}
