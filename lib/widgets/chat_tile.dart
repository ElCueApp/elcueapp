import 'package:flutter/material.dart';
import 'package:elcueapp/chat_screen.dart';

class ChatTile extends StatelessWidget {
  final String chatId;
  final String lastMessage;
  final DateTime timeStamp;
  final Map<String, dynamic> receiverData;

  const ChatTile({
    super.key,
    required this.chatId,
    required this.lastMessage,
    required this.timeStamp,
    required this.receiverData,
    required TextStyle textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return lastMessage.isNotEmpty
        ? ListTile(
            leading: CircleAvatar(
              radius: 25,
              backgroundImage: NetworkImage(receiverData['imageUrl']),
            ),
            title: Text(
              receiverData['name'] ?? 'Unknown',
              style: TextStyle(
                  color: Color(0xFFFAD7DB), fontWeight: FontWeight.bold),
            ),
            subtitle: Text(lastMessage,
                maxLines: 2, style: TextStyle(color: Color(0xFFFAD7DB))),
            trailing: Text(
              '${timeStamp.hour.toString().padLeft(2, '0')}:${timeStamp.minute.toString().padLeft(2, '0')}',
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFFFAD7DB),
              ),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatScreen(
                    chatId: chatId,
                    receiverId: receiverData['uid'],
                  ),
                ),
              );
            },
          )
        : Container();
  }
}
