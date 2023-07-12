import 'package:chat_app/widgets/message_bubble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatMessages extends StatelessWidget {
  const ChatMessages({super.key});

  @override
  Widget build(BuildContext context) {
    final authenticatedUser = FirebaseAuth.instance.currentUser!;

    return Container(
      decoration: BoxDecoration(
        color: Colors.blue[300],
      ),
      child: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('chat')
            .orderBy(
              'createdAt',
              descending: true,
            )
            .snapshots(),
        builder: (ctx, chatSnapshots) {
          if (chatSnapshots.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (!chatSnapshots.hasData || chatSnapshots.data!.docs.isEmpty) {
            return const Center(
              child: Text('No messages found.'),
            );
          }
          if (chatSnapshots.hasError) {
            return const Center(
              child: Text('Something went wrong...'),
            );
          }

          final loadedMessages = chatSnapshots.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.only(
              bottom: 40,
              left: 13,
              right: 13,
            ),
            reverse: true,
            itemCount: loadedMessages.length,
            itemBuilder: (ctx, idx) {
              final chatMessage = loadedMessages[idx].data();
              final nextChatMessage = idx + 1 < loadedMessages.length
                  ? loadedMessages[idx + 1].data()
                  : null;
              final currentMessageUserId = chatMessage['userId'];
              final nextMessageUserId =
                  nextChatMessage != null ? nextChatMessage['userId'] : null;
              final nextUserIsSame = currentMessageUserId == nextMessageUserId;

              if (nextUserIsSame) {
                return MessageBubble.next(
                  time: chatMessage['createdAt'],
                  message: chatMessage['text'],
                  isMe: authenticatedUser.uid == currentMessageUserId,
                );
              } else {
                return MessageBubble.first(
                  time: chatMessage['createdAt'],
                  userImage: chatMessage['userImage'],
                  username: chatMessage['username'],
                  message: chatMessage['text'],
                  isMe: authenticatedUser.uid == currentMessageUserId,
                );
              }
            },
          );
        },
      ),
    );
  }
}
