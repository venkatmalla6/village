import 'quiz_question.dart';

class QuizFolder {
  final String id;
  final String title;
  final String description;
  final int createdAt;
  final List<QuizQuestion> questions;

  QuizFolder({
    required this.id,
    required this.title,
    required this.description,
    required this.createdAt,
    required this.questions,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'createdAt': createdAt,
      'questions': questions.map((q) => q.toMap()).toList(),
    };
  }

  factory QuizFolder.fromMap(Map<String, dynamic> map) {
    return QuizFolder(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      createdAt: map['createdAt'] ?? 0,
      questions: map['questions'] != null
          ? List<QuizQuestion>.from(
              (map['questions'] as List).map((x) => QuizQuestion.fromMap(x)))
          : [],
    );
  }
}
