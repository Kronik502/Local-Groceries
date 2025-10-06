import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'private_chat_screen.dart';

class ChatListPage extends StatelessWidget {
  const ChatListPage({super.key});

  String _getChatId(String uid1, String uid2) {
    return uid1.hashCode <= uid2.hashCode ? '${uid1}_$uid2' : '${uid2}_$uid1';
  }

  /// Fetch the **last** message in a chat with `otherUserId`, if any.
  Future<DatabaseEvent?> _getLastMessageSnapshot(String chatId) {
    return FirebaseDatabase.instance
        .ref('chats/$chatId/messages')
        .orderByChild('timestamp')
        .limitToLast(1)
        .once();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return Scaffold(
        backgroundColor: Color(0xFFF8FAFC),
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFF6366F1).withOpacity(0.3),
                        blurRadius: 20,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.chat_bubble_outline_rounded,
                    size: 64,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 24),
                Text(
                  'Login Required',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                SizedBox(height: 12),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 48),
                  child: Text(
                    'You must be logged in to view chat users.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF64748B),
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Custom Header
            Container(
              padding: EdgeInsets.fromLTRB(24, 24, 24, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Color(0xFF6366F1).withOpacity(0.3),
                              blurRadius: 12,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.chat_bubble_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Messages',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                              letterSpacing: -0.5,
                            ),
                          ),
                          Text(
                            'Chat with other users',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // User List
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('users').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            color: Color(0xFF6366F1),
                            strokeWidth: 3,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Loading users...',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  if (!snapshot.hasData) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline_rounded,
                            size: 64,
                            color: Color(0xFFEF4444),
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Failed to load users',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  final users = snapshot.data!.docs
                      .where((doc) => doc.id != currentUser.uid)
                      .toList();

                  if (users.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: EdgeInsets.all(32),
                            decoration: BoxDecoration(
                              color: Color(0xFFF1F5F9),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.people_outline_rounded,
                              size: 64,
                              color: Color(0xFF64748B),
                            ),
                          ),
                          SizedBox(height: 24),
                          Text(
                            'No users yet',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Check back later',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      final user = users[index];
                      final data = user.data() as Map<String, dynamic>? ?? {};

                      final fullName = (data['fullName'] as String?)?.trim() ?? 'User';
                      final profileImage = data['profileImage'] as String?;

                      final chatId = _getChatId(currentUser.uid, user.id);

                      return FutureBuilder<DatabaseEvent?>(
                        future: _getLastMessageSnapshot(chatId),
                        builder: (context, lastMsgSnap) {
                          String subtitleText = 'Start new chat';
                          bool hasMsg = false;
                          bool myWasRead = false;
                          int? msgTimestamp;
                          String? msgText;

                          if (lastMsgSnap.hasData && lastMsgSnap.data!.snapshot.value != null) {
                            final m = lastMsgSnap.data!.snapshot.value as Map<dynamic, dynamic>;
                            // the `once().snapshot.value` when using limitToLast may return a map keyed by message IDs
                            // so we get the first entry
                            m.entries.forEach((entry) {
                              final msg = entry.value as Map<dynamic, dynamic>;
                              subtitleText = msg['text']?.toString() ?? '';
                              msgTimestamp = (msg['timestamp'] as int?);
                              // check read status: if I am the sender, read = true means other read it
                              if (msg['senderId'] == currentUser.uid) {
                                myWasRead = (msg['read'] == true);
                              }
                              hasMsg = true;
                            });
                          }

                          return Container(
                            margin: EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  blurRadius: 10,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(16),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => PrivateChatScreen(
                                        otherUserId: user.id,
                                        otherUserName: fullName,
                                      ),
                                    ),
                                  );
                                },
                                child: Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Row(
                                    children: [
                                      // Avatar
                                      Container(
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          gradient: profileImage == null
                                              ? LinearGradient(
                                                  colors: [
                                                    Color(0xFF14B8A6),
                                                    Color(0xFF06B6D4),
                                                  ],
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                )
                                              : null,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Color(0xFF6366F1).withOpacity(0.2),
                                              blurRadius: 8,
                                              offset: Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: CircleAvatar(
                                          radius: 28,
                                          backgroundColor: Colors.transparent,
                                          backgroundImage: profileImage != null
                                              ? MemoryImage(base64Decode(profileImage))
                                              : null,
                                          child: profileImage == null
                                              ? Text(
                                                  fullName.isNotEmpty
                                                      ? fullName[0].toUpperCase()
                                                      : 'U',
                                                  style: TextStyle(
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                  ),
                                                )
                                              : null,
                                        ),
                                      ),

                                      SizedBox(width: 16),

                                      // User Info + message snippet
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            // Name
                                            Text(
                                              fullName,
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                color: Color(0xFF0F172A),
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            SizedBox(height: 4),
                                            // Subtitle: either “Start new chat” or last message + tick
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    subtitleText,
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      color: Color(0xFF64748B),
                                                    ),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                if (hasMsg) ...[
                                                  SizedBox(width: 6),
                                                  Icon(
                                                    myWasRead ? Icons.done_all : Icons.check,
                                                    size: 14,
                                                    color: myWasRead
                                                        ? Colors.green
                                                        : Color(0xFF64748B),
                                                  ),
                                                ],
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),

                                      // Timestamp
                                      if (hasMsg && msgTimestamp != null) ...[
                                        SizedBox(width: 8),
                                        Text(
                                         _formatTime(msgTimestamp!),

                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Color(0xFF94A3B8),
                                          ),
                                        ),
                                      ],

                                      // Arrow
                                      Container(
                                        padding: EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Color(0xFFF8FAFC),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Icon(
                                          Icons.arrow_forward_ios_rounded,
                                          size: 16,
                                          color: Color(0xFF6366F1),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
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
      ),
    );
  }

  String _formatTime(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
