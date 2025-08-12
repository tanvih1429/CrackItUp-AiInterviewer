import UIKit

class SubtopicViewController: UIViewController {
    var roundId: String = ""
    var chapterId: String = ""
    
    private var subtopics: [Subtopic] = []
    private let tableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Subtopics"
        view.backgroundColor = .systemBackground
        setupTableView()
        fetchSubtopics()
    }
    
    private func setupTableView() {
        tableView.frame = view.bounds
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "SubtopicCell")
        view.addSubview(tableView)
    }
    
    private func fetchSubtopics() {
        FirestoreService.shared.fetchSubtopics(roundId: roundId, chapterId: chapterId) { [weak self] subs in
            self?.subtopics = subs
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
    }
}

extension SubtopicViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { subtopics.count }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SubtopicCell", for: indexPath)
        cell.textLabel?.text = subtopics[indexPath.row].title
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let subtopic = subtopics[indexPath.row]
        let vc = QuestionViewController()
        vc.roundId = roundId
        vc.chapterId = chapterId
        vc.subtopicId = subtopic.id
        navigationController?.pushViewController(vc, animated: true)
    }
}
