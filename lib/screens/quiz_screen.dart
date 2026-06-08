import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/data_provider.dart';
import '../models/quiz_folder.dart';
import '../models/quiz_question.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  QuizFolder? _selectedFolder;
  int _currentIndex = 0;
  int _score = 0;
  bool _isFinished = false;
  Map<int, int> _userAnswers = {};
  Set<int> _reviewedQuestions = {};
  Map<String, String> _folderScores = {};
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _goToQuestion(int index) {
    setState(() => _currentIndex = index);
    
    double offset = index * 48.0 - 150;
    if (offset < 0) offset = 0;
    
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        offset,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _loadScores();
  }

  Future<void> _loadScores() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _folderScores = Map<String, String>.from(
        json.decode(prefs.getString('quiz_scores') ?? '{}')
      );
    });
  }

  Future<void> _saveScore(String folderId, String scoreStr) async {
    final prefs = await SharedPreferences.getInstance();
    _folderScores[folderId] = scoreStr;
    await prefs.setString('quiz_scores', json.encode(_folderScores));
    setState(() {});
  }

  void _submitAnswer(int index) {
    setState(() {
      _userAnswers[_currentIndex] = index;
    });
  }

  void _finishQuiz() {
    int currentScore = 0;
    final questions = _selectedFolder!.questions;
    for (int i = 0; i < questions.length; i++) {
      if (_userAnswers[i] == questions[i].correctAnswerIndex) {
        currentScore++;
      }
    }
    setState(() {
      _score = currentScore;
      _isFinished = true;
    });
    _saveScore(_selectedFolder!.id, "$_score/${questions.length}");
  }

  void _restartQuiz() {
    setState(() {
      _currentIndex = 0;
      _score = 0;
      _isFinished = false;
      _userAnswers = {};
      _reviewedQuestions = {};
    });
  }

  void _backToFolders() {
    setState(() {
      _selectedFolder = null;
      _currentIndex = 0;
      _score = 0;
      _isFinished = false;
      _userAnswers = {};
      _reviewedQuestions = {};
    });
  }

  @override
  Widget build(BuildContext context) {
    final folders = context.watch<DataProvider>().quizFolders;

    return Container(
      color: Colors.grey[50],
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_selectedFolder == null)
                Expanded(child: _buildFolderSelection(folders))
              else if (_selectedFolder!.questions.isEmpty)
                _buildNoQuestions()
              else if (_isFinished)
                _buildResultScreen(_selectedFolder!.questions.length)
              else
                _buildQuizUI(_selectedFolder!.questions[_currentIndex], _selectedFolder!.questions.length),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFolderSelection(List<QuizFolder> folders) {
    if (folders.isEmpty) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.folder_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 20),
          Text("No Quiz Sets Available", style: GoogleFonts.outfit(fontSize: 20)),
          Text("Admin is preparing new quizzes for you!", style: GoogleFonts.inter(color: Colors.grey[500])),
        ],
      );
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text("Select a Quiz Topic", style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.bold, color: const Color(0xFF2D5A27))),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(20),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 300,
              childAspectRatio: 0.9,
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
            ),
            itemCount: folders.length,
            itemBuilder: (context, index) {
              final folder = folders[index];
              return Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _selectedFolder = folder;
                      _currentIndex = 0;
                      _score = 0;
                      _isFinished = false;
                      _userAnswers = {};
                      _reviewedQuestions = {};
                    });
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.quiz, size: 50, color: Color(0xFF2D5A27)),
                        const SizedBox(height: 15),
                        Text(folder.title, style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                        const SizedBox(height: 5),
                        Text("${folder.questions.length} questions", style: GoogleFonts.inter(color: Colors.grey[600])),
                        if (_folderScores.containsKey(folder.id)) ...[
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(color: Colors.green[50], borderRadius: BorderRadius.circular(10)),
                            child: Text("Best Score: ${_folderScores[folder.id]}", style: GoogleFonts.inter(color: Colors.green[800], fontWeight: FontWeight.bold, fontSize: 12)),
                          ),
                        ]
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildNoQuestions() {
    return Column(
      children: [
        Icon(Icons.quiz_outlined, size: 80, color: Colors.grey[300]),
        const SizedBox(height: 20),
        Text("This quiz folder has no questions.", style: GoogleFonts.outfit(fontSize: 20)),
        const SizedBox(height: 20),
        ElevatedButton(onPressed: _backToFolders, child: const Text("Go Back")),
      ],
    );
  }

  Widget _buildQuizUI(QuizQuestion question, int total) {
    return Card(
      elevation: 10,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      color: Colors.white,
      margin: const EdgeInsets.all(20),
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          children: [
            // Top Bar: Question Numbers
            Row(
              children: [
                IconButton(icon: const Icon(Icons.arrow_back), onPressed: _backToFolders),
                Expanded(
                  child: SizedBox(
                    height: 45,
                    child: ListView.builder(
                      controller: _scrollController,
                      scrollDirection: Axis.horizontal,
                      itemCount: total,
                      itemBuilder: (context, i) {
                        Color bgColor = Colors.grey[100]!;
                        Color textColor = Colors.grey[600]!;
                        Color borderColor = Colors.transparent;

                        if (_reviewedQuestions.contains(i)) {
                          bgColor = Colors.yellow[100]!;
                          textColor = Colors.orange[800]!;
                          borderColor = Colors.orange;
                        } else if (_userAnswers.containsKey(i)) {
                          bgColor = Colors.green[100]!;
                          textColor = Colors.green[800]!;
                          borderColor = Colors.green;
                        }

                        if (_currentIndex == i) {
                          borderColor = const Color(0xFF2D5A27);
                        }

                        return GestureDetector(
                          onTap: () => _goToQuestion(i),
                          child: Container(
                            width: 40,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              color: bgColor,
                              border: Border.all(color: borderColor, width: _currentIndex == i ? 2 : 1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Text("${i + 1}", style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            Text(
              question.question,
              style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, height: 1.4),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            ...List.generate(question.options.length, (index) => _optionButton(index, question.options[index], question.correctAnswerIndex)),
            const SizedBox(height: 40),
            // Bottom Action Bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: _currentIndex > 0 ? () => _goToQuestion(_currentIndex - 1) : null,
                  child: const Text("Previous"),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      if (_reviewedQuestions.contains(_currentIndex)) {
                        _reviewedQuestions.remove(_currentIndex);
                      } else {
                        _reviewedQuestions.add(_currentIndex);
                      }
                    });
                  },
                  icon: Icon(_reviewedQuestions.contains(_currentIndex) ? Icons.bookmark_remove : Icons.bookmark_add, size: 18),
                  label: Text(_reviewedQuestions.contains(_currentIndex) ? "Unmark Review" : "Mark Review"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange[50],
                    foregroundColor: Colors.orange[900],
                  ),
                ),
                if (_currentIndex < total - 1)
                  ElevatedButton(
                    onPressed: () => _goToQuestion(_currentIndex + 1),
                    child: const Text("Next"),
                  )
                else
                  ElevatedButton(
                    onPressed: _finishQuiz,
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2D5A27), foregroundColor: Colors.white),
                    child: const Text("Submit"),
                  ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _optionButton(int index, String text, int correctIdx) {
    bool isSelected = _userAnswers[_currentIndex] == index;

    Color borderColor = Colors.grey[200]!;
    Color bgColor = Colors.white;
    
    if (isSelected) {
      borderColor = const Color(0xFF2D5A27);
      bgColor = const Color(0xFF2D5A27).withOpacity(0.05);
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: InkWell(
        onTap: () => _submitAnswer(index),
        borderRadius: BorderRadius.circular(15),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          decoration: BoxDecoration(
            color: bgColor,
            border: Border.all(color: borderColor, width: 2),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF2D5A27) : Colors.grey[100],
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    String.fromCharCode(65 + index),
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Text(text, style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w500)),
              ),
              if (isSelected) const Icon(Icons.check_circle, color: Color(0xFF2D5A27)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultScreen(int total) {
    double percentage = (_score / total) * 100;
    String feedback = percentage > 80 ? "Amazing Knowledge!" : 
                       percentage > 50 ? "Good Job!" : "Keep Learning!";

    return Card(
      elevation: 10,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      child: Padding(
        padding: const EdgeInsets.all(50),
        child: Column(
          children: [
            Text("🎉 Quiz Completed!", style: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.bold, color: const Color(0xFF2D5A27))),
            const SizedBox(height: 30),
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 150,
                  height: 150,
                  child: CircularProgressIndicator(
                    value: percentage / 100,
                    strokeWidth: 12,
                    backgroundColor: Colors.grey[100],
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2D5A27)),
                  ),
                ),
                Column(
                  children: [
                    Text("$_score/$total", style: GoogleFonts.outfit(fontSize: 38, fontWeight: FontWeight.bold)),
                    Text("SCORE", style: GoogleFonts.inter(color: Colors.grey[600], fontSize: 14)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 30),
            Text(feedback, style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: _restartQuiz,
              icon: const Icon(Icons.replay),
              label: const Text("RESTART QUIZ"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2D5A27),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
            ),
            const SizedBox(height: 15),
            TextButton.icon(
              onPressed: _backToFolders,
              icon: const Icon(Icons.folder),
              label: const Text("BACK TO FOLDERS"),
            ),
          ],
        ),
      ),
    );
  }
}
