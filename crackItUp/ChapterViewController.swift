import UIKit

class ChapterViewController: UIViewController {
    var roundId: String = ""
    var fieldId: String? = nil
    var syllabusId: String? = nil
    
    private var chapters: [Chapter] = []
    private let tableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Chapters"
        view.backgroundColor = .systemBackground
        setupTableView()
        fetchChapters()
    }
    
    private func setupTableView() {
        tableView.frame = view.bounds
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "ChapterCell")
        view.addSubview(tableView)
    }
    
    private func fetchChapters() {
        FirestoreService.shared.fetchChapters(roundId: roundId) { [weak self] chapters in
            self?.chapters = chapters
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
    }
}

extension ChapterViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { chapters.count }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChapterCell", for: indexPath)
        cell.textLabel?.text = chapters[indexPath.row].title
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let chapter = chapters[indexPath.row]
        let vc = SubtopicViewController()
        vc.roundId = roundId
        vc.chapterId = chapter.id
        navigationController?.pushViewController(vc, animated: true)
    }
}
