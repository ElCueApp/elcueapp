import 'package:elcueapp/chat_provider.dart';
import 'package:elcueapp/page/create_channel_screen.dart';
import 'package:elcueapp/search_screen.dart';
import 'package:elcueapp/page/video_call_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:elcueapp/widgets/chat_tile.dart'; // Sesuaikan dengan nama file yang sesuai
import 'package:elcueapp/login_screen.dart'; // Sesuaikan dengan nama file yang sesuai

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late User? loggedInUser;

  @override
  void initState() {
    super.initState();
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

  Future<Map<String, dynamic>> _fetchChatData(String chatId) async {
    final chatDoc =
        await FirebaseFirestore.instance.collection('chats').doc(chatId).get();
    final chatData = chatDoc.data() as Map<String, dynamic>?;
    if (chatData != null) {
      final users = chatData['users'] as List<dynamic>;
      final receiverId =
          users.firstWhere((id) => id != loggedInUser!.uid, orElse: () => '');
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(receiverId)
          .get();
      final userData = userDoc.data() as Map<String, dynamic>?;
      return {
        'chatId': chatId,
        'lastMessage': chatData['lastMessage'] ?? '',
        'timestamp': chatData['timestamp']?.toDate() ?? DateTime.now(),
        'userData': userData,
      };
    }
    return {};
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: Color(0xFF0021AC),
        appBar: AppBar(
          iconTheme: IconThemeData(color: Color(0xFFFAD7DB)), // Set icon color
          backgroundColor: Color(0xFF0021AC),
          title: Text(
            'ElCue',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFFFAD7DB), // Warna teks ElCue menjadi pink muda
            ),
          ),
          actions: [
            IconButton(
              onPressed: () {
                // Fungsi ini akan dipanggil ketika video call button diklik
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CreateChannelScreen()),  // Ganti dengan halaman video call yang sesuai
                );
              },
              icon: Icon(Icons.video_call, color: Color(0xFFFAD7DB)),
            ),
            IconButton(
              onPressed: () {
                _auth.signOut();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
              icon: const Icon(Icons.logout, color: Color(0xFFFAD7DB)),
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: chatProvider.getChats(loggedInUser!.uid),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final chatDocs = snapshot.data!.docs;
                  return FutureBuilder<List<Map<String, dynamic>>>(
                    future: Future.wait(
                        chatDocs.map((chatDoc) => _fetchChatData(chatDoc.id))),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final chatDataList = snapshot.data!;
                      return ListView.builder(
                        itemCount: chatDataList.length,
                        itemBuilder: (context, index) {
                          final chatData = chatDataList[index];
                          return ChatTile(
                            chatId: chatData['chatId'],
                            lastMessage: chatData['lastMessage'],
                            timeStamp: chatData['timestamp'],
                            receiverData: chatData['userData'],
                            textStyle: TextStyle(
                                color: Color(
                                    0xFFFAD7DB)), // Warna teks riwayat chat menjadi pink muda
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: const Color(0xFFFAD7DB),
          foregroundColor: Color(0xFF0021AC),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SearchScreen()),
            );
          },
          child: const Icon(Icons.search, color: Color(0xFF0021AC)),
        ),
      ),
    );
  }
}
