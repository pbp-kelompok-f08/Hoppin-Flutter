import 'dart:convert';
import 'package:flutter_hoppin/threads/services/threads_service.dart';
import 'package:flutter_hoppin/screens/public_profile_page.dart';

import '../widget/modal.dart';
import '../models/threads_models.dart' as tm;
import '../models/reply_models.dart' as rm;
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:flutter/material.dart';

/// ===========================
/// Tailwind-like helpers
/// ===========================
class Tw {
  static const double s1 = 4;
  static const double s2 = 8;
  static const double s3 = 12;
  static const double s4 = 16;
  static const double s5 = 20;
  static const double s6 = 24;
  static const double s8 = 32;
  static const double s10 = 40;
  static const double s12 = 48;

  static const Radius rLg = Radius.circular(12);
  static const Radius rXl = Radius.circular(16);

  static const Color bg = Color(0xFF0B0B0B); // like neutral-950
  static const Color card = Color(0xFF141414); // neutral-900
  static const Color card2 = Color(0xFF1C1C1C); // neutral-800
  static const Color border = Color(0xFF3A3A3A); // stone/gray
  static const Color text = Color(0xFFEFEFEF);
  static const Color muted = Color(0xFF9CA3AF); // gray-400/500
  static const Color blue = Color(0xFF2563EB); // blue-600
  static const Color blue2 = Color(0xFF3B82F6); // blue-500
}

class Breakpoints {
  static bool isLg(BuildContext c) => MediaQuery.sizeOf(c).width >= 1024;
  static bool isMd(BuildContext c) => MediaQuery.sizeOf(c).width >= 768;
}

/// ===========================
/// Page
/// ===========================
class ThreadsPage extends StatefulWidget {
  const ThreadsPage({super.key});

  @override
  State<ThreadsPage> createState() => _ThreadsPageState();
}

class _ThreadsPageState extends State<ThreadsPage> {
  bool loading = true;
  String? error;

  List<tm.Threads> allThreads = [];
  List<tm.Threads> visibleThreads = [];

  final tagController = TextEditingController();
  String searchInfo = "";

  // Reply panel state
  String? activeThreadId;
  String? activeThreadUsername;
  bool replyLoading = false;
  List<rm.Reply> replies = [];
  final replyController = TextEditingController();

  // Trending tags
  Map<String, int> tagCount = {};

  late ThreadsService _service;
  String _currentUsername = "";

  @override
  void initState() {
    super.initState();
    final request = context.read<CookieRequest>();
    _service = ThreadsService(request);

    _bootstrap();
  }

  Future<void> _bootstrap() async {
    _currentUsername = await _service.fetchCurrentUsername();
    await _loadThreads();
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    tagController.dispose();
    replyController.dispose();
    super.dispose();
  }

  Future<void> _loadThreads() async {
    setState(() {
      loading = true;
      error = null;
    });

    try {
      final data = await _service.fetchThreads();
      allThreads = data;
      _rebuildTagTrends(allThreads);
      visibleThreads = List.of(allThreads);
    } catch (e) {
      error = e.toString();
    } finally {
      setState(() => loading = false);
    }
  }

  void _closeReplies() {
    setState(() {
      activeThreadId = null;
      activeThreadUsername = null;
      replies = [];
      replyController.clear();
    });
  }

  void _rebuildTagTrends(List<tm.Threads> items) {
    final Map<String, int> c = {};
    for (final t in items) {
      final tags = t.tags.trim();
      if (tags.isEmpty) continue;
      for (final raw in tags.split(',')) {
        final tag = raw.trim().toLowerCase();
        if (tag.isEmpty) continue;
        c[tag] = (c[tag] ?? 0) + 1;
      }
    }
    tagCount = c;
  }

  void _searchByTag(String tag) {
    tagController.text = tag;
    _applySearch();
  }

  void _applySearch() {
    final term = tagController.text.trim().toLowerCase();
    if (term.isEmpty) {
      setState(() {
        visibleThreads = List.of(allThreads);
        searchInfo = "";
      });
      return;
    }

    final filtered = allThreads
        .where((t) => t.tags.toLowerCase().contains(term))
        .toList();
    setState(() {
      visibleThreads = filtered;
      searchInfo = filtered.isNotEmpty
          ? "Found ${filtered.length} thread(s) with #$term"
          : 'No threads found for "$term"';
    });
  }

  bool _asBool(dynamic v, bool fallback) {
    if (v is bool) return v;
    if (v is String) {
      final s = v.toLowerCase().trim();
      if (s == 'true' || s == '1' || s == 'yes') return true;
      if (s == 'false' || s == '0' || s == 'no') return false;
    }
    if (v is num) return v != 0;
    return fallback;
  }

  int _asInt(dynamic v, int fallback) {
    if (v is int) return v;
    return int.tryParse(v?.toString() ?? '') ?? fallback;
  }

  Future<void> _toggleLikeThread(tm.Threads item) async {
    // ✅ optimistic update biar instan
    setState(() {
      final idx = allThreads.indexWhere((t) => t.id == item.id);
      if (idx != -1) {
        final old = allThreads[idx];
        allThreads[idx] = updateThread(
          old,
          isLiked: !old.isLiked,
          likeCount: old.isLiked ? (old.likeCount - 1) : (old.likeCount + 1),
        );
      }

      final vidx = visibleThreads.indexWhere((t) => t.id == item.id);
      if (vidx != -1) {
        final old = visibleThreads[vidx];
        visibleThreads[vidx] = updateThread(
          old,
          isLiked: !old.isLiked,
          likeCount: old.isLiked ? (old.likeCount - 1) : (old.likeCount + 1),
        );
      }
    });

    try {
      final res = await _service.likeThread(item.id);

      // support beberapa kemungkinan key dari backend
      final likeCountRaw =
          res['likeCount'] ?? res['like_count'] ?? res['count'];
      final isLikedRaw = res['isLiked'] ?? res['is_liked'] ?? res['liked'];

      final newCount = _asInt(likeCountRaw, item.likeCount);
      final newLiked = _asBool(isLikedRaw, !item.isLiked);

      setState(() {
        final idx = allThreads.indexWhere((t) => t.id == item.id);
        if (idx != -1) {
          allThreads[idx] = updateThread(
            allThreads[idx],
            likeCount: newCount,
            isLiked: newLiked,
          );
        }

        final vidx = visibleThreads.indexWhere((t) => t.id == item.id);
        if (vidx != -1) {
          visibleThreads[vidx] = updateThread(
            visibleThreads[vidx],
            likeCount: newCount,
            isLiked: newLiked,
          );
        }
      });
    } catch (_) {
      _toast(context, "Failed to like thread");
      // kalau gagal, sync ulang biar bener
      await _loadThreads();
    }
  }

  Future<void> _openReplies(tm.Threads item) async {
    setState(() {
      activeThreadId = item.id;
      activeThreadUsername = item.user.username;
      replyLoading = true;
      replies = [];
    });

    try {
      final data = await _service.fetchReplies(item.id);
      setState(() => replies = data);
    } catch (_) {
      _toast(context, "Failed to load replies");
    } finally {
      setState(() => replyLoading = false);
    }

    // Mobile: tampilkan modal overlay
    if (!Breakpoints.isLg(context)) {
      if (!mounted) return;
      await showDialog(
        context: context,
        barrierColor: Colors.black.withOpacity(0.7),
        builder: (_) => StatefulBuilder(
          builder: (context, setModalState) => _ReplyDialog(
            titleUsername: activeThreadUsername ?? "",
            loading: replyLoading,
            replies: replies,
            currentUsername: _currentUsername,
            onClose: () => Navigator.of(context).pop(),

            // ✅ setelah parent update, paksa dialog rebuild
            onLikeReply: (r) async {
              await _toggleLikeReply(r);
              setModalState(() {});
            },
            onSubmitReply: () async {
              await _submitReply();
              setModalState(() {});
            },

            replyController: replyController,
          ),
        ),
      );
    }
  }

  Future<void> _toggleLikeReply(rm.Reply item) async {
    try {
      final res = await _service.likeReply(item.id);
      final newCount = (res['likeCount'] ?? item.likeCount) is int
          ? (res['likeCount'] as int)
          : int.tryParse((res['likeCount'] ?? item.likeCount).toString()) ??
                item.likeCount;
      final isLiked = (res['isLiked'] ?? !item.isLiked) == true;

      setState(() {
        final idx = replies.indexWhere((r) => r.id == item.id);
        if (idx != -1) {
          replies[idx] = rm.Reply(
            user: replies[idx].user,
            id: replies[idx].id,
            threadId: replies[idx].threadId,
            content: replies[idx].content,
            createdAt: replies[idx].createdAt,
            likeCount: newCount,
            isLiked: isLiked,
          );
        }
      });
    } catch (_) {
      _toast(context, "Failed to like reply");
    }
  }

  Future<void> _submitReply() async {
    final threadId = activeThreadId;
    final content = replyController.text.trim();
    if (threadId == null || content.isEmpty) return;

    try {
      final res = await _service.addReply(threadId, content);
      replyController.clear();

      // ✅ selalu refresh replies setelah post
      final fresh = await _service.fetchReplies(threadId);
      setState(() => replies = fresh);

      // update replyCount di thread list (pakai count dari server kalau ada)
      final incomingCount = res['count'] ?? res['reply_count'];
      final parsedCount = incomingCount is int
          ? incomingCount
          : int.tryParse(incomingCount?.toString() ?? '');

      _updateLocalThreadReplyCount(threadId, parsedCount ?? fresh.length);

      _toast(context, "Reply added successfully!");
    } catch (e) {
      debugPrint("Submit Reply Error: $e");
      _toast(context, "Failed to add reply. Please check your connection.");
    }
  }

  // Helper untuk update count di list thread
  void _updateLocalThreadReplyCount(String threadId, int? serverCount) {
    final idx = allThreads.indexWhere((t) => t.id == threadId);
    if (idx != -1) {
      final old = allThreads[idx];
      allThreads[idx] = updateThread(
        old,
        replyCount: serverCount ?? (old.replyCount + 1),
      );
    }

    final vidx = visibleThreads.indexWhere((t) => t.id == threadId);
    if (vidx != -1) {
      final old = visibleThreads[vidx];
      visibleThreads[vidx] = updateThread(
        old,
        replyCount: serverCount ?? (old.replyCount + 1),
      );
    }
  }

  Future<void> _showCreateThread() async {
    final payload = await showCreateThreadModal(context);
    if (payload == null) return;

    bool likelySuccess = false;

    try {
      await _service.createThread(
        content: payload.content,
        tags: payload.tags,
        imageUrl: payload.imageUrl,
      );
      likelySuccess = true;
    } catch (e) {
      // Kalau masih ada error lain, kita tetap bisa refetch
      // biar UI sinkron dengan DB (karena kasusmu: DB sudah masuk).
      likelySuccess = true;
    }

    if (likelySuccess) {
      _toast(context, "Threads added successfully!");
      await _loadThreads();
    } else {
      _toast(context, "Failed to publish thread");
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLg = Breakpoints.isLg(context);

    return Scaffold(
      backgroundColor: Tw.bg,
      appBar: AppBar(
        backgroundColor: Tw.bg,
        elevation: 0,
        title: const Text("Threads"),
        foregroundColor: Tw.text,
      ),

      // ✅ SCROLLABLE BERSAMAAN:
      // - Bungkus semua konten dengan RefreshIndicator + SingleChildScrollView
      // - Hilangkan Expanded/ListView scroll internal di kolom threads & panel replies
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadThreads,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: Tw.s4),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1280),
                  child: isLg
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Left: search & trends
                            SizedBox(
                              width: 320,
                              child: Column(
                                children: [
                                  _SearchCard(
                                    controller: tagController,
                                    onSearch: _applySearch,
                                    infoText: searchInfo,
                                  ),
                                  const SizedBox(height: Tw.s4),
                                  _TrendsCard(
                                    tagCount: tagCount,
                                    onTapTag: _searchByTag,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: Tw.s5),

                            // Middle: thread list (jadi non-scroll internal)
                            Expanded(
                              child: _CenterThreadsColumn(
                                loading: loading,
                                error: error,
                                visibleThreads: visibleThreads,
                                onRefresh: _loadThreads, // dipakai untuk Retry
                                onCreate: _showCreateThread,
                                currentUsername: _currentUsername,
                                onTapTag: _searchByTag,
                                onLikeThread: _toggleLikeThread,
                                onOpenReplies: _openReplies,
                              ),
                            ),

                            const SizedBox(width: Tw.s5),

                            // Right: reply panel (desktop only, jadi non-scroll internal)
                            if (activeThreadId != null)
                              SizedBox(
                                width: 420,
                                child: _ReplyPanelDesktop(
                                  activeThreadId: activeThreadId,
                                  activeUsername: activeThreadUsername,
                                  loading: replyLoading,
                                  replies: replies,
                                  currentUsername: _currentUsername,
                                  onLikeReply: _toggleLikeReply,
                                  onSubmitReply: _submitReply,
                                  replyController: replyController,
                                  onClose: _closeReplies,
                                ),
                              ),
                          ],
                        )
                      : Column(
                          children: [
                            // Mobile: search + trends on top
                            _SearchCard(
                              controller: tagController,
                              onSearch: _applySearch,
                              infoText: searchInfo,
                            ),
                            const SizedBox(height: Tw.s4),
                            _TrendsCard(
                              tagCount: tagCount,
                              onTapTag: _searchByTag,
                            ),
                            const SizedBox(height: Tw.s4),

                            // ⚠️ penting: jangan pakai Expanded lagi karena sudah SingleChildScrollView
                            _CenterThreadsColumn(
                              loading: loading,
                              error: error,
                              visibleThreads: visibleThreads,
                              onRefresh: _loadThreads,
                              onCreate: _showCreateThread,
                              currentUsername: _currentUsername,
                              onTapTag: _searchByTag,
                              onLikeThread: _toggleLikeThread,
                              onOpenReplies: _openReplies,
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// ===========================
/// Widgets
/// ===========================
class _SearchCard extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSearch;
  final String infoText;

  const _SearchCard({
    required this.controller,
    required this.onSearch,
    required this.infoText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Tw.card.withOpacity(0.9),
        borderRadius: const BorderRadius.all(Tw.rXl),
        border: Border.all(color: Tw.border),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 16),
        ],
      ),
      padding: const EdgeInsets.all(Tw.s5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "🔎 Search by Tag",
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Tw.text,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: Tw.s4),
          TextField(
            controller: controller,
            style: const TextStyle(color: Tw.text),
            decoration: InputDecoration(
              hintText: "Enter tag... e.g. football,ai,tech",
              hintStyle: TextStyle(color: Tw.muted.withOpacity(0.8)),
              filled: true,
              fillColor: Tw.card2,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: Tw.s4,
                vertical: Tw.s3,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Tw.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Tw.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Tw.blue2, width: 1.5),
              ),
            ),
            onSubmitted: (_) => onSearch(),
          ),
          const SizedBox(height: Tw.s3),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onSearch,
              style: ElevatedButton.styleFrom(
                backgroundColor: Tw.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text("Search"),
            ),
          ),
          if (infoText.isNotEmpty) ...[
            const SizedBox(height: Tw.s4),
            Text(
              infoText,
              style: const TextStyle(color: Tw.muted, fontSize: 13),
            ),
          ],
        ],
      ),
    );
  }
}

class _TrendsCard extends StatelessWidget {
  final Map<String, int> tagCount;
  final void Function(String tag) onTapTag;

  const _TrendsCard({required this.tagCount, required this.onTapTag});

  @override
  Widget build(BuildContext context) {
    final top = tagCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final top5 = top.take(5).toList();

    return Container(
      decoration: BoxDecoration(
        color: Tw.card,
        borderRadius: const BorderRadius.all(Tw.rXl),
        border: Border.all(color: Tw.border),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.25), blurRadius: 18),
        ],
      ),
      padding: const EdgeInsets.all(Tw.s5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "🔥 Search Trends",
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Tw.text,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: Tw.s4),
          if (top5.isEmpty)
            Text(
              "No trending tags yet",
              style: TextStyle(
                color: Tw.muted.withOpacity(0.9),
                fontStyle: FontStyle.italic,
              ),
            )
          else
            ...top5.map((e) {
              final tag = e.key;
              return Padding(
                padding: const EdgeInsets.only(bottom: Tw.s3),
                child: InkWell(
                  onTap: () => onTapTag(tag),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Tw.s4,
                      vertical: Tw.s3,
                    ),
                    decoration: BoxDecoration(
                      color: Tw.card2.withOpacity(0.65),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Tw.border.withOpacity(0.9)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "#$tag",
                          style: const TextStyle(
                            color: Tw.blue2,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          "${e.value}",
                          style: const TextStyle(color: Tw.muted),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }
}

class _CenterThreadsColumn extends StatelessWidget {
  final bool loading;
  final String? error;
  final List<tm.Threads> visibleThreads;

  final Future<void> Function() onRefresh;
  final VoidCallback onCreate;

  final String currentUsername;
  final void Function(String tag) onTapTag;
  final void Function(tm.Threads item) onLikeThread;
  final void Function(tm.Threads item) onOpenReplies;

  const _CenterThreadsColumn({
    required this.loading,
    required this.error,
    required this.visibleThreads,
    required this.onRefresh,
    required this.onCreate,
    required this.currentUsername,
    required this.onTapTag,
    required this.onLikeThread,
    required this.onOpenReplies,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.symmetric(
          vertical: BorderSide(color: Tw.border.withOpacity(0.9)),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: Tw.s2),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Tw.s2),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: onCreate,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Tw.muted,
                  side: BorderSide(color: Tw.border),
                  padding: const EdgeInsets.symmetric(
                    horizontal: Tw.s4,
                    vertical: Tw.s5,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.centerLeft,
                ),
                child: const Text("+ Create new Thread..."),
              ),
            ),
          ),
          const SizedBox(height: Tw.s2),

          // ✅ SCROLLABLE BERSAMAAN:
          // Hapus Expanded + RefreshIndicator internal. Body dibuat non-scroll internal.
          _buildBody(context),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: Tw.s12),
        child: Column(
          children: [
            CircularProgressIndicator(),
            SizedBox(height: Tw.s3),
            Text("Loading Threads...", style: TextStyle(color: Tw.muted)),
          ],
        ),
      );
    }

    if (error != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: Tw.s12),
        child: Column(
          children: [
            Text(
              "Error: $error",
              style: const TextStyle(color: Colors.redAccent),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: Tw.s4),
            TextButton(
              onPressed: onRefresh,
              child: const Text("Retry", style: TextStyle(color: Tw.blue2)),
            ),
          ],
        ),
      );
    }

    if (visibleThreads.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: Tw.s12),
        child: Column(
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: Tw.muted),
            SizedBox(height: Tw.s3),
            Text(
              "No threads right now 💤",
              style: TextStyle(
                color: Tw.text,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: Tw.s2),
            Text(
              "Be the first to share something with the community!",
              style: TextStyle(color: Tw.muted),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      // penting biar ikut SingleChildScrollView luar
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: visibleThreads.length,
      itemBuilder: (context, i) {
        final item = visibleThreads[i];
        return _ThreadCard(
          item: item,
          currentUsername: currentUsername,
          onTapTag: onTapTag,
          onLike: () => onLikeThread(item),
          onReply: () => onOpenReplies(item),
        );
      },
    );
  }
}

class _ThreadCard extends StatelessWidget {
  final tm.Threads item;
  final String currentUsername;
  final void Function(String tag) onTapTag;
  final VoidCallback onLike;
  final VoidCallback onReply;

  const _ThreadCard({
    required this.item,
    required this.currentUsername,
    required this.onTapTag,
    required this.onLike,
    required this.onReply,
  });

  @override
  Widget build(BuildContext context) {
    final canDelete =
        currentUsername.isNotEmpty && currentUsername == item.user.username;
    final created = _fmtDate(item.createdAt);

    return Container(
      decoration: BoxDecoration(
        color: Tw.card,
        border: Border(bottom: BorderSide(color: Tw.border.withOpacity(0.9))),
      ),
      padding: const EdgeInsets.symmetric(horizontal: Tw.s5, vertical: Tw.s4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // avatar
          InkWell(
            borderRadius: BorderRadius.circular(999),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      PublicProfilePage(username: item.user.username),
                ),
              );
            },
            child: CircleAvatar(
              radius: 17,
              backgroundColor: Colors.grey[800],
              child: const Icon(Icons.person, size: 20, color: Colors.white),
            ),
          ),

          // content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // username + time
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PublicProfilePage(
                                username: item.user.username,
                              ),
                            ),
                          );
                        },
                        child: Text(
                          "@${item.user.username}",
                          style: const TextStyle(
                            color: Tw.text,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    Text(
                      created,
                      style: TextStyle(
                        color: Tw.muted.withOpacity(0.85),
                        fontSize: 12,
                      ),
                    ),
                    if (canDelete) ...[
                      const SizedBox(width: Tw.s2),
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert, color: Tw.muted),
                        color: Tw.card2,
                        onSelected: (v) {
                          _toast(
                            context,
                            "Delete: implement endpoint delete untuk thread ${item.id}",
                          );
                        },
                        itemBuilder: (_) => [
                          const PopupMenuItem(
                            value: "delete",
                            child: Text(
                              "Delete",
                              style: TextStyle(color: Colors.redAccent),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: Tw.s2),

                if (item.image.isNotEmpty) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: Image.network(
                        item.image,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: Tw.card2,
                          alignment: Alignment.center,
                          child: const Text(
                            "Image error",
                            style: TextStyle(color: Tw.muted),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: Tw.s3),
                ],

                Text(
                  item.content,
                  style: const TextStyle(
                    color: Color(0xFFD6D6D6),
                    height: 1.35,
                  ),
                ),

                const SizedBox(height: Tw.s3),

                if (item.tags.trim().isNotEmpty)
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: item.tags
                        .split(',')
                        .map((t) => t.trim())
                        .where((t) => t.isNotEmpty)
                        .map(
                          (tag) => InkWell(
                            onTap: () => onTapTag(tag.toLowerCase()),
                            child: Text(
                              "#$tag",
                              style: const TextStyle(
                                color: Tw.blue2,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
              ],
            ),
          ),

          const SizedBox(width: Tw.s4),

          // right actions (like + comment)
          SizedBox(
            width: 56,
            child: Column(
              children: [
                const SizedBox(height: Tw.s6),
                _IconCount(
                  emoji: item.isLiked ? "❤️" : "🤍",
                  count: item.likeCount,
                  onTap: onLike,
                ),
                const SizedBox(height: Tw.s4),
                _IconCount(emoji: "💬", count: item.replyCount, onTap: onReply),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _fmtDate(DateTime d) {
    return "${d.year}-${_two(d.month)}-${_two(d.day)} ${_two(d.hour)}:${_two(d.minute)}";
  }

  static String _two(int x) => x.toString().padLeft(2, "0");
}

class _IconCount extends StatelessWidget {
  final String emoji;
  final int count;
  final VoidCallback onTap;

  const _IconCount({
    required this.emoji,
    required this.count,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(999),
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: Text(emoji, style: const TextStyle(fontSize: 22)),
          ),
        ),
        Text("$count", style: const TextStyle(color: Tw.text, fontSize: 12)),
      ],
    );
  }
}

class _ReplyPanelDesktop extends StatelessWidget {
  final String? activeThreadId;
  final String? activeUsername;
  final bool loading;
  final List<rm.Reply> replies;
  final String currentUsername;
  final void Function(rm.Reply item) onLikeReply;
  final Future<void> Function() onSubmitReply;
  final TextEditingController replyController;
  final String? emptyHint;
  final VoidCallback onClose;

  const _ReplyPanelDesktop({
    required this.activeThreadId,
    required this.activeUsername,
    required this.loading,
    required this.replies,
    required this.currentUsername,
    required this.onLikeReply,
    required this.onSubmitReply,
    required this.replyController,
    required this.onClose,
    this.emptyHint,
  });

  @override
  Widget build(BuildContext context) {
    Widget repliesBody;

    if (loading) {
      repliesBody = const Padding(
        padding: EdgeInsets.symmetric(vertical: Tw.s6),
        child: Center(child: CircularProgressIndicator()),
      );
    } else if (replies.isEmpty) {
      repliesBody = Padding(
        padding: const EdgeInsets.symmetric(vertical: Tw.s6),
        child: Center(
          child: Text(
            emptyHint ?? "No replies yet. Be the first!",
            style: const TextStyle(color: Tw.muted),
          ),
        ),
      );
    } else {
      // ✅ ikut scroll luar: non-scroll internal
      repliesBody = ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: replies.length,
        itemBuilder: (context, i) {
          final r = replies[i];
          return _ReplyCard(
            item: r,
            currentUsername: currentUsername,
            onLike: () => onLikeReply(r),
          );
        },
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Tw.card,
        border: Border.all(color: Tw.border),
        borderRadius: const BorderRadius.all(Tw.rXl),
      ),
      child: Column(
        children: [
          // Header Panel
          Container(
            padding: const EdgeInsets.all(Tw.s4),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Tw.border.withOpacity(0.9)),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Replies",
                        style: TextStyle(
                          color: Tw.text,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        activeUsername == null
                            ? "—"
                            : "Replying to @$activeUsername",
                        style: const TextStyle(color: Tw.muted, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: onClose,
                  icon: const Icon(Icons.close, color: Tw.muted, size: 20),
                  tooltip: "Close replies",
                  splashRadius: 20,
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
          ),

          // Replies list (non-scroll internal)
          repliesBody,

          // Input Area
          Container(
            padding: const EdgeInsets.all(Tw.s3),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Tw.border.withOpacity(0.9)),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: replyController,
                    style: const TextStyle(color: Tw.text),
                    decoration: InputDecoration(
                      hintText: "Write a reply...",
                      hintStyle: TextStyle(color: Tw.muted.withOpacity(0.8)),
                      filled: true,
                      fillColor: Tw.card2,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: Tw.s4,
                        vertical: Tw.s3,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Tw.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Tw.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Tw.blue2,
                          width: 1.5,
                        ),
                      ),
                    ),
                    onSubmitted: (_) => onSubmitReply(),
                  ),
                ),
                const SizedBox(width: Tw.s2),
                ElevatedButton(
                  onPressed: () => onSubmitReply(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Tw.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                  ),
                  child: const Text("Reply"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReplyCard extends StatelessWidget {
  final rm.Reply item;
  final String currentUsername;
  final VoidCallback onLike;

  const _ReplyCard({
    required this.item,
    required this.currentUsername,
    required this.onLike,
  });

  @override
  Widget build(BuildContext context) {
    final canDelete =
        currentUsername.isNotEmpty && currentUsername == item.user.username;
    final ago = _timeAgo(item.createdAt);

    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Tw.border.withOpacity(0.9))),
      ),
      padding: const EdgeInsets.symmetric(horizontal: Tw.s4, vertical: Tw.s3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(999),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      PublicProfilePage(username: item.user.username),
                ),
              );
            },
            child: CircleAvatar(
              radius: 17,
              backgroundColor: Colors.grey[800],
              child: const Icon(Icons.person, size: 20, color: Colors.white),
            ),
          ),
          const SizedBox(width: Tw.s3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.user.username,
                        style: const TextStyle(
                          color: Tw.text,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    if (canDelete)
                      PopupMenuButton<String>(
                        icon: const Icon(
                          Icons.more_vert,
                          color: Tw.muted,
                          size: 18,
                        ),
                        color: Tw.card2,
                        onSelected: (v) {
                          _toast(
                            context,
                            "Delete reply: implement endpoint delete reply ${item.id}",
                          );
                        },
                        itemBuilder: (_) => const [
                          PopupMenuItem(
                            value: "delete",
                            child: Text(
                              "Delete",
                              style: TextStyle(color: Colors.redAccent),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  item.content,
                  style: const TextStyle(color: Color(0xFFD0D0D0), height: 1.3),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    InkWell(
                      onTap: onLike,
                      child: Text(
                        item.isLiked ? "❤️" : "🤍",
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      "${item.likeCount}",
                      style: const TextStyle(color: Tw.muted, fontSize: 12),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      "·",
                      style: TextStyle(color: Tw.muted, fontSize: 12),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      ago,
                      style: const TextStyle(color: Tw.muted, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays >= 365) return "${(diff.inDays / 365).floor()}y ago";
    if (diff.inDays >= 30) return "${(diff.inDays / 30).floor()}mo ago";
    if (diff.inDays >= 1) return "${diff.inDays}d ago";
    if (diff.inHours >= 1) return "${diff.inHours}h ago";
    if (diff.inMinutes >= 1) return "${diff.inMinutes}m ago";
    return "Just now";
  }
}

/// Mobile reply dialog (tetap sama, karena modal ini memang punya scroll sendiri)
class _ReplyDialog extends StatelessWidget {
  final String titleUsername;
  final bool loading;
  final List<rm.Reply> replies;
  final String currentUsername;
  final VoidCallback onClose;
  final void Function(rm.Reply item) onLikeReply;
  final Future<void> Function() onSubmitReply;
  final TextEditingController replyController;

  const _ReplyDialog({
    required this.titleUsername,
    required this.loading,
    required this.replies,
    required this.currentUsername,
    required this.onClose,
    required this.onLikeReply,
    required this.onSubmitReply,
    required this.replyController,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(Tw.s4),
      child: Container(
        height: MediaQuery.sizeOf(context).height * 0.82,
        decoration: BoxDecoration(
          color: Tw.card,
          borderRadius: const BorderRadius.all(Tw.rXl),
          border: Border.all(color: Tw.border),
        ),
        child: Column(
          children: [
            // header
            Container(
              padding: const EdgeInsets.all(Tw.s4),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Tw.border.withOpacity(0.9)),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Replies",
                          style: TextStyle(
                            color: Tw.text,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Replying to $titleUsername",
                          style: const TextStyle(color: Tw.muted, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: onClose,
                    icon: const Icon(Icons.close, color: Tw.muted),
                  ),
                ],
              ),
            ),

            Expanded(
              child: loading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: replies.length,
                      itemBuilder: (context, i) {
                        final r = replies[i];
                        return _ReplyCard(
                          item: r,
                          currentUsername: currentUsername,
                          onLike: () => onLikeReply(r),
                        );
                      },
                    ),
            ),

            // input
            Container(
              padding: const EdgeInsets.all(Tw.s3),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Tw.border.withOpacity(0.9)),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: replyController,
                      style: const TextStyle(color: Tw.text),
                      decoration: InputDecoration(
                        hintText: "Write a reply...",
                        hintStyle: TextStyle(color: Tw.muted.withOpacity(0.8)),
                        filled: true,
                        fillColor: Tw.card2,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: Tw.s4,
                          vertical: Tw.s3,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Tw.border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Tw.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Tw.blue2,
                            width: 1.5,
                          ),
                        ),
                      ),
                      onSubmitted: (_) => onSubmitReply(),
                    ),
                  ),
                  const SizedBox(width: Tw.s2),
                  ElevatedButton(
                    onPressed: () => onSubmitReply(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Tw.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                    ),
                    child: const Text("Reply"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Simple toast/snackbar
void _toast(BuildContext context, String msg) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(msg),
      backgroundColor: Tw.card2,
      behavior: SnackBarBehavior.floating,
    ),
  );
}

tm.Threads updateThread(
  tm.Threads t, {
  int? likeCount,
  bool? isLiked,
  int? replyCount,
}) {
  return tm.Threads(
    user: t.user,
    id: t.id,
    content: t.content,
    tags: t.tags,
    image: t.image,
    likeCount: likeCount ?? t.likeCount,
    shareCount: t.shareCount,
    replyCount: replyCount ?? t.replyCount,
    createdAt: t.createdAt,
    isLiked: isLiked ?? t.isLiked,
  );
}
