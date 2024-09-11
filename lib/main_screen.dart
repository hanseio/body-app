import 'package:flutter/material.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});  // 수정된 부분

  @override
  MainScreenState createState() => MainScreenState();  // 수정된 부분
}

class MainScreenState extends State<MainScreen> {  // 수정된 부분
  final TextEditingController _messageController = TextEditingController();
  final List<String> _chatHistory = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Buddy와 대화하기')),  // const 추가
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _chatHistory.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_chatHistory[index]),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(  // const 추가
                      hintText: '메시지를 입력하세요...',
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),  // const 추가
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage() {
    if (_messageController.text.isNotEmpty) {
      setState(() {
        _chatHistory.add('나: ${_messageController.text}');
        // TODO: AI 응답 로직 구현
        _chatHistory.add('Buddy: AI 응답이 여기에 들어갑니다.');
      });
      _messageController.clear();
    }
  }
}
