import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elcueapp/chat_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:elcueapp/calling_screen.dart';
import 'chat_provider.dart';

class ChatScreen extends StatefulWidget {
  final String? chatId;
  final String receiverId;

  const ChatScreen({Key? key, required this.chatId, required this.receiverId}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  User? loggedInUser;
  String? chatId;

  @override
  void initState() {
    super.initState();
    chatId = widget.chatId;
    getCurrentUser();
  }

  void getCurrentUser() {
    final user = _auth.currentUser;
    if (user != null) {
      setState(() {
        loggedInUser = user;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);
    final TextEditingController _textController = TextEditingController();

    return FutureBuilder<DocumentSnapshot>(
      future: _firestore.collection('users').doc(widget.receiverId).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          final receiverData = snapshot.data!.data() as Map<String, dynamic>;

          return Scaffold(
            backgroundColor: Color(0xFFFAD7DB),
            appBar: AppBar(
              iconTheme: IconThemeData(color: Color(0xFF0021AC)),
              backgroundColor: Color(0xFFFAD7DB),
              title: Row(
                children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(receiverData['imageUrl']),
                  ),
                  SizedBox(width: 10),
                  Text(receiverData['name'], style: TextStyle(color: Color(0xFF0021AC))),
                ],
              ),
              actions: [
                IconButton(
                  icon: Icon(Icons.video_call, color: Color(0xFF0021AC)),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CallingScreen(receiverId: widget.receiverId)),
                    );
                  },
                ),
              ],
            ),
            body: Column(
              children: [
                Expanded(
                  child: chatId != null && chatId!.isNotEmpty
                      ? MessagesStream(chatId: chatId!)
                      : Center(
                          child: Text("Belum ada pesan."),
                        ),
                ),
                Container(
                  color: Color(0xFFFAD7DB),
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 15),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _textController,
                          decoration: InputDecoration(
                            hintText: "Ketik pesan...",
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () async {
                          if (_textController.text.isNotEmpty) {
                            if (chatId == null || chatId!.isEmpty) {
                              chatId = await chatProvider.createChatRoom(widget.receiverId);
                            }
                            if (chatId != null) {
                              chatProvider.sendMessage(chatId!, _textController.text, widget.receiverId);
                              _textController.clear();
                            }
                          }
                        },
                        icon: Icon(
                          Icons.send,
                          color: Color(0xFF0021AC),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }
        return Scaffold(
          appBar: AppBar(),
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }
}

class MessagesStream extends StatelessWidget {
  final String chatId;

  const MessagesStream({Key? key, required this.chatId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        final messages = snapshot.data!.docs;
        List<Widget> messageWidgets = [];
        DateTime? currentDate;

        for (int i = messages.length - 1; i >= 0; i--) {
          final messageData = messages[i].data() as Map<String, dynamic>;
          final messageText = messageData['messageBody'];
          final messageSender = messageData['senderId'];
          final timestamp = messageData['timestamp'] ?? FieldValue.serverTimestamp();

          final currentUser = FirebaseAuth.instance.currentUser!.uid;

          final messageTime = (timestamp is Timestamp) ? timestamp.toDate() : DateTime.now();
          final dateFormat = DateFormat('dd MMM yyyy');

          // Add date bubble if it's a new day
          if (currentDate == null || !isSameDay(messageTime, currentDate)) {
            messageWidgets.add(DateBubble(date: messageTime));
            currentDate = messageTime;
          }

          messageWidgets.add(MessageBubble(
            sender: messageSender,
            text: messageText,
            isMe: currentUser == messageSender,
            timestamp: timestamp,
          ));
        }

        return ListView(
          reverse: true, // Reverse order to display latest messages at the bottom
          children: messageWidgets.reversed.toList(),
        );
      },
    );
  }

  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year && date1.month == date2.month && date1.day == date2.day;
  }
}

class MessageBubble extends StatelessWidget {
  final String sender;
  final String text;
  final bool isMe;
  final dynamic timestamp;

  const MessageBubble({
    Key? key,
    required this.sender,
    required this.text,
    required this.isMe,
    this.timestamp,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final DateTime messageTime = (timestamp is Timestamp) ? timestamp.toDate() : DateTime.now();
    final String formattedTime = DateFormat('HH:mm').format(messageTime);

    return Padding(
      padding: EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  spreadRadius: 2,
                ),
              ],
              borderRadius: isMe
                  ? BorderRadius.only(
                      topLeft: Radius.circular(15),
                      bottomLeft: Radius.circular(15),
                      bottomRight: Radius.circular(15),
                    )
                  : BorderRadius.only(
                      topRight: Radius.circular(15),
                      bottomLeft: Radius.circular(15),
                      bottomRight: Radius.circular(15),
                    ),
              color: isMe ? Color(0xFF0021AC) : Color(0xFFFAD7DB),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    text,
                    style: TextStyle(
                      color: isMe ? Color(0xFFFAD7DB) : Color(0xFF0021AC),
                      fontSize: 15,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    formattedTime,
                    style: TextStyle(
                      color: isMe ? Color(0xFFFAD7DB) : Color(0xFF0021AC),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DateBubble extends StatelessWidget {
  final DateTime date;

  const DateBubble({Key? key, required this.date}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String formattedDate = DateFormat('dd MMM yyyy').format(date);

    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Center(
        child: Text(
          formattedDate,
          style: TextStyle(
            color: Color(0xFF0021AC),
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
