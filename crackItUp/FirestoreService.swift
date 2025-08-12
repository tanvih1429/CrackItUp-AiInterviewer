import Foundation
import FirebaseFirestore
struct Round: Identifiable {
    let id: String
    let title: String
}

struct Chapter: Identifiable {
    let id: String
    let title: String
}

struct Subtopic: Identifiable {
    let id: String
    let title: String
}

struct Question: Codable, Identifiable {
    @DocumentID var id: String?
    var prompt: String
    var options: [String]?   // present only for MCQs
    var correctIndex: Int?   // only for MCQs
    var answer: String?      // could be for coding or descriptive
    var type: String         // e.g. "mcq", "coding", "theory"
}
struct MCQ {
    var id: String
    var prompt: String
    var options: [String]
    var correctIndex: Int
}

struct Field: Identifiable {
    let id: String
    let title: String
}

struct Syllabus: Identifiable {
    let id: String
    let title: String
}

final class FirestoreService {
    @MainActor static let shared = FirestoreService()
    private let db = Firestore.firestore()
    
    private init() {}
    
    // Fetch Rounds
    func fetchRounds(completion: @escaping ([Round]) -> Void) {
        db.collection("rounds").getDocuments { snapshot, error in
            guard let docs = snapshot?.documents else { completion([]); return }
            let rounds = docs.map { Round(id: $0.documentID, title: $0["title"] as? String ?? "") }
            completion(rounds)
        }
    }
    
    // Fetch Chapters
    func fetchChapters(roundId: String, completion: @escaping ([Chapter]) -> Void) {
        db.collection("rounds").document(roundId).collection("chapters").getDocuments { snapshot, error in
            guard let docs = snapshot?.documents else { completion([]); return }
            let chapters = docs.map { Chapter(id: $0.documentID, title: $0["title"] as? String ?? "") }
            completion(chapters)
        }
    }
    
    // Fetch Subtopics
    func fetchSubtopics(roundId: String, chapterId: String, completion: @escaping ([Subtopic]) -> Void) {
        db.collection("rounds").document(roundId).collection("chapters").document(chapterId).collection("subtopics").getDocuments { snapshot, error in
            guard let docs = snapshot?.documents else { completion([]); return }
            let subtopics = docs.map { Subtopic(id: $0.documentID, title: $0["title"] as? String ?? "") }
            completion(subtopics)
        }
    }
    
    // Fetch Questions
    // Fetch Questions
    func fetchQuestions(roundId: String, chapterId: String?, subtopicId: String?, completion: @escaping ([Question]) -> Void) {
        var collection: CollectionReference
        
        if let subId = subtopicId, let chapId = chapterId {
            collection = db.collection("rounds")
                .document(roundId)
                .collection("chapters")
                .document(chapId)
                .collection("subtopics")
                .document(subId)
                .collection("questions")
        } else if let chapId = chapterId {
            collection = db.collection("rounds")
                .document(roundId)
                .collection("chapters")
                .document(chapId)
                .collection("questions")
        } else {
            completion([])
            return
        }
        
        collection.getDocuments { snapshot, error in
            guard let docs = snapshot?.documents else { completion([]); return }
            let questions = docs.map {
                Question(
                    id: $0.documentID,
                    prompt: $0["prompt"] as? String ?? "",
                    options: $0["options"] as? [String],
                    correctIndex: $0["correctIndex"] as? Int,
                    answer: $0["answer"] as? String,
                    type: $0["type"] as? String ?? "mcq"
                )
            }

            completion(questions)
        }
    }

    // Fetch Fields (for Coding Round)
    func fetchFields(roundId: String, completion: @escaping ([Field]) -> Void) {
        db.collection("rounds").document(roundId).collection("fields").getDocuments { snapshot, error in
            guard let docs = snapshot?.documents else { completion([]); return }
            let fields = docs.map { Field(id: $0.documentID, title: $0["title"] as? String ?? "") }
            completion(fields)
        }
    }
    
    // Fetch Syllabus (inside Fields)
    func fetchSyllabus(roundId: String, fieldId: String, completion: @escaping ([Syllabus]) -> Void) {
        db.collection("rounds").document(roundId).collection("fields").document(fieldId).collection("syllabus").getDocuments { snapshot, error in
            guard let docs = snapshot?.documents else { completion([]); return }
            let syllabus = docs.map { Syllabus(id: $0.documentID, title: $0["title"] as? String ?? "") }
            completion(syllabus)
        }
    }
}
