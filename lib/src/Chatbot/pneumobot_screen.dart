import 'package:finalfyp/src/Chatbot/chat_Service.dart';
import 'package:flutter/material.dart';

class ChatBotScreen extends StatefulWidget {
  const ChatBotScreen({super.key});

  @override
  _ChatBotScreenState createState() => _ChatBotScreenState();
}

class _ChatBotScreenState extends State<ChatBotScreen> {
  final ChatService _chatService = ChatService();
  final TextEditingController _messageController = TextEditingController();
  bool _isTyping = false;
  bool _isActive = true; // Manage active status dynamically

  void _sendMessage() async {
    final userMessage = _messageController.text.trim();
    if (userMessage.isEmpty) return;

    setState(() {
      _chatService.addUserMessage(userMessage);
      _isTyping = true;
    });

    _messageController.clear();

    // Fetch the bot's response
    await _chatService.fetchBotResponse(userMessage);

    setState(() {
      _isTyping = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF010713),
        elevation: 0,
        title: Row(
          children: [
            ClipOval(
              child: Image.asset(
                'Asset/images/chatbot.png',
                width: 40,
                height: 40,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Pneumobot',
                    style: TextStyle(
                      fontFamily: 'Poppinsregular',
                      fontSize: 25,
                      color: Colors.white,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 5,
                        backgroundColor:
                        _isActive ? Colors.green : Colors.red, // Dynamic
                      ),
                      const SizedBox(width: 5),
                      Text(
                        _isActive ? 'Active Status' : 'Inactive',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF010713),
                Color(0xFF0D2962),
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    reverse: true,
                    itemCount: _chatService.messages.length + (_isTyping ? 1 : 0),
                    itemBuilder: (context, index) {
                      // If typing, show a "Typing..." indicator at the top.
                      if (_isTyping && index == 0) {
                        return Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            constraints: BoxConstraints(
                              maxWidth: screenWidth * 0.7,
                            ),
                            padding: const EdgeInsets.all(15),
                            margin: const EdgeInsets.symmetric(
                                vertical: 5, horizontal: 10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'Typing...',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        );
                      }

                      final messageIndex = _isTyping ? index - 1 : index;
                      final message = _chatService.messages[messageIndex];
                      final isUser = message['type'] == 'user';

                      return Align(
                        alignment:
                        isUser ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          constraints: BoxConstraints(
                            maxWidth: screenWidth * 0.7, // Limit the width
                          ),
                          padding: const EdgeInsets.all(15),
                          margin: const EdgeInsets.symmetric(
                            vertical: 5,
                            horizontal: 10,
                          ),
                          decoration: BoxDecoration(
                            color: isUser ? Colors.grey[300] : Colors.white,
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(20),
                              topRight: const Radius.circular(20),
                              bottomLeft: isUser
                                  ? const Radius.circular(20)
                                  : const Radius.circular(5),
                              bottomRight: isUser
                                  ? const Radius.circular(5)
                                  : const Radius.circular(20),
                            ),
                          ),
                          child: Text(
                            message['message']!,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _messageController,
                          onChanged: (value) {
                            setState(() {});
                          },
                          decoration: InputDecoration(
                            hintText: 'Type a message...',
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 15,
                              vertical: 10,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: _messageController.text.trim().isNotEmpty
                            ? _sendMessage
                            : null,
                        child: CircleAvatar(
                          backgroundColor: _messageController.text.trim().isNotEmpty
                              ? Colors.black
                              : Colors.grey, // Dynamic color
                          child: const Icon(
                            Icons.send,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
