import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:elcueapp/chat_provider.dart';
import 'chat_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _auth = FirebaseAuth.instance;

  User? loggedInUser;
  String searchQuery = '';

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

  void handleSearch(String query) {
    setState(() {
      searchQuery = query;
    });
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);

    return Scaffold(
      backgroundColor: Color(0xFFFAD7DB),
      appBar: AppBar(
        title: const Text("Search Users",
            style: TextStyle(
                color: Color(0xFF0021AC), fontWeight: FontWeight.bold)),
        backgroundColor: Color(0xFFFAD7DB), // Set app bar background color
        iconTheme: IconThemeData(color: Color(0xFF0021AC)), // Set icon color
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search Users...",
                prefixIcon: Icon(Icons.search,
                    color: Color(0xFF0021AC)), // Set search icon color
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: handleSearch,
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: searchQuery.isEmpty
                  ? Stream.empty()
                  : chatProvider.searchUsers(searchQuery),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
                final users = snapshot.data!.docs;
                List<UserTile> userWidgets = [];
                for (var user in users) {
                  final userData = user.data() as Map<String, dynamic>;
                  if (userData['uid'] != loggedInUser!.uid) {
                    final userWidget = UserTile(
                      userId: userData['uid'],
                      name: userData['name'],
                      email: userData['email'],
                      imageUrl: userData['imageUrl'],
                    );
                    userWidgets.add(userWidget);
                  }
                }
                return ListView(
                  children: userWidgets,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class UserTile extends StatelessWidget {
  final String userId;
  final String name;
  final String email;
  final String imageUrl;

  const UserTile({
    required this.userId,
    required this.name,
    required this.email,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: NetworkImage(imageUrl),
      ),
      title: Text(
        name,
        style: TextStyle(
          color: Color(0xFF0021AC), // Set name text color
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(
        email,
        style: TextStyle(
          color: Color(0xFF0021AC)
              .withOpacity(0.8), // Set email text color with opacity
        ),
      ),
      onTap: () async {
        final chatId = await chatProvider.getChatRoom(userId) ??
            await chatProvider.createChatRoom(userId);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(
              chatId: chatId,
              receiverId: userId,
            ),
          ),
        );
      },
    );
  }
}
