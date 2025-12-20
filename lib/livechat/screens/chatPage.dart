import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_hoppin/colors.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

import '../models/chat_model.dart';
import '../widgets/chatItem.dart';

class ChatListPage extends StatefulWidget {
  final String groupId;
  final String groupName;

  const ChatListPage({super.key, required this.groupId, required this.groupName});

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<Chat> _chats = [];
  final Set<String> _chatIds = {}; // dedup

  Timer? _pollingTimer;
  bool _isSending = false;
  bool _isInitialLoading = true;

  Future<void> editChat(String chatId, String newMessage) async {
    final request = context.read<CookieRequest>();

    try {
      final response = await request.post(
        'http://localhost:8000/liveChat/chat/update/$chatId/',
        jsonEncode({
          "_method": "PATCH",
          "message": newMessage,
        }),
      );

      final updatedChat = Chat.fromJson(response["data"]);

      setState(() {
        final index = _chats.indexWhere((c) => c.id == chatId);
        if (index != -1) {
          _chats[index] = updatedChat;
        }
      });
    } catch (e) {
      debugPrint('Edit chat failed: $e');
    }
  }

  Future<void> deleteChat(String chatId) async {
    final request = context.read<CookieRequest>();

    try {
      await request.post(
        'http://localhost:8000/liveChat/chat/delete/$chatId/',
        jsonEncode({
          "_method": "DELETE",
        }),
      );

      setState(() {
        _chats.removeWhere((c) => c.id == chatId);
        _chatIds.remove(chatId);
      });
    } catch (e) {
      debugPrint('Delete chat failed: $e');
    }
  }


  Future<void> refreshChat() async {
    final request = context.read<CookieRequest>();

    final chats = await fetchChat(request);

    setState(() {
      _chats
        ..clear()
        ..addAll(chats);

      _chatIds
        ..clear()
        ..addAll(chats.map((c) => c.id));
    });

    _scrollToBottom();
}

  // ================= FETCH =================
  Future<List<Chat>> fetchChat(CookieRequest request) async {
    final response = await request.get(
      'http://localhost:8000/liveChat/chat/${widget.groupId}/',
    );

    final datas = response["data"] as List;

    final chats = datas.map((e) => Chat.fromJson(e)).toList();

    // ⬅️ INI KUNCINYA
    return chats.reversed.toList();
  }


  // ================= POLL + DIFF =================
  Future<void> pollChat(CookieRequest request) async {
    final fetchedChats = await fetchChat(request);

    final newChats = fetchedChats.where(
      (c) => !_chatIds.contains(c.id),
    );

    if (newChats.isNotEmpty) {
      setState(() {
        for (final chat in newChats) {
          _chats.add(chat);
          _chatIds.add(chat.id);
        }
      });

      _scrollToBottom();
    }

    if (_isInitialLoading) {
      setState(() => _isInitialLoading = false);
    }
  }

  void startPolling(CookieRequest request) {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(
      const Duration(seconds: 3),
      (_) {
        if (!mounted) return;
        pollChat(request);
      },
    );
  }

  // ================= SEND =================
  Future<void> sendMessage(CookieRequest request) async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _isSending) return;

    setState(() => _isSending = true);

    // ✅ LANGSUNG KOSONG (DAN TIDAK PERNAH DIISI LAGI)
    _messageController.clear();

    try {
      final response = await request.post(
        'http://localhost:8000/liveChat/chat/${widget.groupId}/',
        jsonEncode({
          "message": text,
          "replyTo": null,
        }),
      );

      final newChat = Chat.fromJson(response["data"]);

      setState(() {
        _chats.add(newChat);
        _chatIds.add(newChat.id);
      });

      _scrollToBottom();
    } catch (e) {
      // ❌ JANGAN balikin text
      // cukup kasih feedback kalau mau
      debugPrint('Send message failed: $e');
    } finally {
      setState(() => _isSending = false);
    }
  }


  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // ================= INIT =================
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final request = context.watch<CookieRequest>();

    if (_chats.isEmpty) {
      pollChat(request);
      startPolling(request);
    }
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.groupName),
      ),

      // ===== CHAT LIST =====
      body: _isInitialLoading
          ? const Center(child: CircularProgressIndicator())
          : _chats.isEmpty
              ? const Center(
                  child: Text(
                    'Belum ada chat',
                    style: TextStyle(fontSize: 16),
                  ),
                )
              : ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(12),
                  itemCount: _chats.length,
                  itemBuilder: (context, index) {
                    Chat chat = _chats[index];
                    return ChatItem(
                      chat: chat,
                      onEdit: (newMessage) async {
                        await editChat(chat.id, newMessage);
                        refreshChat();
                      },
                      onDelete: () async {
                        await deleteChat(chat.id);
                        refreshChat();
                      },
                    );
                  },
                ),

      // ===== SEND BAR =====
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
          decoration: BoxDecoration(
            color: MainColors.secondaryColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _messageController,
                  minLines: 1,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'Ketik pesan...',
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: _isSending
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.send, color: Colors.white),
                onPressed:
                    _isSending ? null : () => sendMessage(request),
              ),
            ],
          ),
        ),
      ),

      backgroundColor: MainColors.primaryColor,
    );
  }

  // ================= CLEANUP =================
  @override
  void dispose() {
    _pollingTimer?.cancel();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
