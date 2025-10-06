import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PrivateChatScreen extends StatefulWidget {
  final String otherUserId;
  final String otherUserName;

  const PrivateChatScreen({
    super.key,
    required this.otherUserId,
    required this.otherUserName,
  });

  @override
  State<PrivateChatScreen> createState() => _PrivateChatScreenState();
}

class _PrivateChatScreenState extends State<PrivateChatScreen> with TickerProviderStateMixin, WidgetsBindingObserver {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  User? currentUser;
  String? otherUserProfileImage;
  bool _isTyping = false;
  bool _isLoadingProfile = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    currentUser = FirebaseAuth.instance.currentUser;
    _loadOtherUserProfile();
    _messageController.addListener(_onTypingChanged);

    _updateMyLastSeen();  // update when opening
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _messageController.removeListener(_onTypingChanged);
    _messageController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();

    _updateMyLastSeen();  // update when leaving
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (currentUser == null) return;
    if (state == AppLifecycleState.resumed) {
      // app in foreground
      _updateMyLastSeen();
    } else if (state == AppLifecycleState.paused) {
      // app in background / closed
      _updateMyLastSeen();
    }
  }

  void _onTypingChanged() {
    final isCurrentlyTyping = _messageController.text.trim().isNotEmpty;
    if (_isTyping != isCurrentlyTyping) {
      setState(() {
        _isTyping = isCurrentlyTyping;
      });
    }
  }

  Future<void> _loadOtherUserProfile() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.otherUserId)
          .get();

      if (doc.exists) {
        setState(() {
          otherUserProfileImage = doc.data()?['profileImage'] as String?;
          _isLoadingProfile = false;
        });
      } else {
        setState(() => _isLoadingProfile = false);
      }
    } catch (e) {
      setState(() => _isLoadingProfile = false);
    }
  }

  Future<void> _updateMyLastSeen() async {
    if (currentUser == null) return;
    final uid = currentUser!.uid;
    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'lastSeen': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  String getChatId(String uid1, String uid2) {
    return uid1.hashCode <= uid2.hashCode ? '${uid1}_$uid2' : '${uid2}_$uid1';
  }

  Future<void> _sendMessage(String chatId) async {
    final text = _messageController.text.trim();
    if (text.isEmpty || currentUser == null) return;

    final messageRef = FirebaseDatabase.instance
        .ref('chats/$chatId/messages')
        .push();

    await messageRef.set({
      'senderId': currentUser!.uid,
      'receiverId': widget.otherUserId,
      'text': text,
      'timestamp': ServerValue.timestamp,
      'read': false,
    });

    _messageController.clear();
    _scrollToBottom();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  String _formatMessageTime(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(date.year, date.month, date.day);

    if (messageDate == today) {
      return DateFormat('h:mm a').format(date);
    } else if (messageDate == today.subtract(const Duration(days: 1))) {
      return 'Yesterday ${DateFormat('h:mm a').format(date)}';
    } else {
      return DateFormat('MMM d, h:mm a').format(date);
    }
  }

  /// Mark messages as read when this user is viewing the chat
  Future<void> _markMessagesAsRead(String chatId, List<DataSnapshot> messages) async {
    for (var snap in messages) {
      final msg = snap.value as Map<dynamic, dynamic>;
      final key = snap.key;
      if (msg['receiverId'] == currentUser!.uid && msg['read'] == false) {
        // update to read
        await FirebaseDatabase.instance
            .ref('chats/$chatId/messages/$key')
            .update({'read': true});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (currentUser == null) {
      return Scaffold(
        backgroundColor: Color(0xFFF8FAFC),
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.lock_rounded,
                  size: 64,
                  color: Color(0xFF64748B),
                ),
                SizedBox(height: 16),
                Text(
                  'You must be logged in to chat',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final chatId = getChatId(currentUser!.uid, widget.otherUserId);
    final messagesRef = FirebaseDatabase.instance
        .ref('chats/$chatId/messages')
        .orderByChild('timestamp');

    return Scaffold(
      backgroundColor: Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: Color(0xFF0F172A)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: otherUserProfileImage == null
                    ? LinearGradient(
                        colors: [Color(0xFF14B8A6), Color(0xFF06B6D4)],
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
                radius: 20,
                backgroundColor: Colors.transparent,
                backgroundImage: otherUserProfileImage != null
                    ? MemoryImage(base64Decode(otherUserProfileImage!))
                    : null,
                child: otherUserProfileImage == null
                    ? Text(
                        widget.otherUserName.isNotEmpty
                            ? widget.otherUserName[0].toUpperCase()
                            : 'U',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      )
                    : null,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.otherUserName,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0F172A),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  // You might want to show last seen of the other user here:
                  StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .doc(widget.otherUserId)
                        .snapshots(),
                    builder: (context, snap) {
                      if (snap.hasData && snap.data!.exists) {
                        final data = snap.data!.data() as Map<String, dynamic>;
                        final ts = data['lastSeen'] as Timestamp?;
                        if (ts != null) {
                          final last = ts.toDate();
                          final diff = DateTime.now().difference(last);
                          String status;
                          if (diff.inSeconds < 60) {
                            status = 'Online';
                          } else if (diff.inMinutes < 60) {
                            status = '${diff.inMinutes}m ago';
                          } else if (diff.inHours < 24) {
                            status = '${diff.inHours}h ago';
                          } else {
                            status = DateFormat('MMM d, h:mm a').format(last);
                          }
                          return Text(
                            status,
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF10B981),
                              fontWeight: FontWeight.w500,
                            ),
                          );
                        }
                      }
                      return Text(
                        'Status...',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF10B981),
                          fontWeight: FontWeight.w500,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<DatabaseEvent>(
                stream: messagesRef.onValue,
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
                            'Loading messages...',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
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
                              Icons.chat_bubble_outline_rounded,
                              size: 64,
                              color: Color(0xFF64748B),
                            ),
                          ),
                          SizedBox(height: 24),
                          Text(
                            'No messages yet',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Start the conversation!',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  final messagesMap = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
                  final entries = messagesMap.entries.toList();
                  // sort by timestamp
                  entries.sort((a, b) {
                    final aTime = a.value['timestamp'] as int? ?? 0;
                    final bTime = b.value['timestamp'] as int? ?? 0;
                    return aTime.compareTo(bTime);
                  });

                  // convert to list of DataSnapshot-like items
                  final snapshots = entries.map((e) {
                    final snap = snapshot.data!.snapshot.child(e.key.toString());
                    return snap;
                  }).toList();

                  // Mark unread messages read when viewing
                  _markMessagesAsRead(chatId, snapshots.cast<DataSnapshot>());

                  WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: snapshots.length,
                    itemBuilder: (context, index) {
                      final snap = snapshots[index];
                      final msg = snap.value as Map<dynamic, dynamic>;
                      final isMe = msg['senderId'] == currentUser!.uid;
                      final timestamp = msg['timestamp'] as int?;
                      final wasRead = (msg['read'] == true);

                      return Padding(
                        padding: EdgeInsets.only(bottom: 12),
                        child: Row(
                          mainAxisAlignment:
                              isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            if (!isMe) ...[
                              Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [Color(0xFF14B8A6), Color(0xFF06B6D4)],
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: CircleAvatar(
                                  radius: 16,
                                  backgroundColor: Colors.transparent,
                                  backgroundImage: otherUserProfileImage != null
                                      ? MemoryImage(base64Decode(otherUserProfileImage!))
                                      : null,
                                  child: otherUserProfileImage == null
                                      ? Text(
                                          widget.otherUserName[0].toUpperCase(),
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        )
                                      : null,
                                ),
                              ),
                              SizedBox(width: 8),
                            ],
                            Flexible(
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                decoration: BoxDecoration(
                                  gradient: isMe
                                      ? LinearGradient(
                                          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        )
                                      : null,
                                  color: isMe ? null : Colors.white,
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(20),
                                    topRight: Radius.circular(20),
                                    bottomLeft: Radius.circular(isMe ? 20 : 4),
                                    bottomRight: Radius.circular(isMe ? 4 : 20),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: isMe
                                          ? Color(0xFF6366F1).withOpacity(0.3)
                                          : Colors.black.withOpacity(0.06),
                                      blurRadius: 8,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                      isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      msg['text'] ?? '',
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: isMe ? Colors.white : Color(0xFF0F172A),
                                        height: 1.4,
                                      ),
                                    ),
                                    if (timestamp != null) ...[
                                      SizedBox(height: 4),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            _formatMessageTime(timestamp),
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: isMe
                                                  ? Colors.white.withOpacity(0.8)
                                                  : Color(0xFF64748B),
                                            ),
                                          ),
                                          SizedBox(width: 6),
                                          if (isMe) ...[
                                            // show tick / read indicator only on my messages
                                            Icon(
                                              wasRead ? Icons.done_all : Icons.check,
                                              size: 14,
                                              color: wasRead
                                                  ? Colors.greenAccent
                                                  : (Colors.white.withOpacity(0.8)),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                            if (isMe) SizedBox(width: 8),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            // Input Area
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              padding: EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: SafeArea(
                top: false,
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: TextField(
                          controller: _messageController,
                          focusNode: _focusNode,
                          textInputAction: TextInputAction.send,
                          onSubmitted: (_) => _sendMessage(chatId),
                          style: TextStyle(
                            fontSize: 15,
                            color: Color(0xFF0F172A),
                          ),
                          decoration: InputDecoration(
                            hintText: "Type a message...",
                            hintStyle: TextStyle(color: Color(0xFF94A3B8)),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                          ),
                          maxLines: null,
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    AnimatedContainer(
                      duration: Duration(milliseconds: 200),
                      child: Material(
                        color: _isTyping
                            ? Color(0xFF6366F1)
                            : Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(24),
                        child: InkWell(
                          onTap: _isTyping ? () => _sendMessage(chatId) : null,
                          borderRadius: BorderRadius.circular(24),
                          child: Container(
                            padding: EdgeInsets.all(12),
                            child: Icon(
                              Icons.send_rounded,
                              color: _isTyping ? Colors.white : Color(0xFF94A3B8),
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
