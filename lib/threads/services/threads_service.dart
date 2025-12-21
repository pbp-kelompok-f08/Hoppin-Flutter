import 'package:pbp_django_auth/pbp_django_auth.dart';

import '../models/threads_models.dart' as tm;
import '../models/reply_models.dart' as rm;

class ThreadsService {
  static const String baseUrl = 'https://dion-wisdom-hoppin.pbp.cs.ui.ac.id';
  final CookieRequest request;

  ThreadsService(this.request);

  Future<List<tm.Threads>> fetchThreads() async {
    final data = await request.get('$baseUrl/threads/json/');
    return (data as List).map((e) => tm.Threads.fromJson(e)).toList();
  }

  Future<void> createThread({
    required String content,
    required String tags,
    required String imageUrl,
  }) async {
    try {
      await request.post('$baseUrl/threads/create-thread-ajax/', {
        'content': content,
        'tags': tags,
        'image': imageUrl,
      });
    } on FormatException {
      // Biasanya terjadi kalau server balikin HTML/redirect/empty,
      // padahal create sudah berhasil di server.
      return;
    }
  }

  Future<Map<String, dynamic>> likeThread(String threadId) async {
    final res = await request.post(
      '$baseUrl/threads/like-thread/$threadId/',
      {},
    );
    return Map<String, dynamic>.from(res);
  }

  Future<List<rm.Reply>> fetchReplies(String threadId) async {
    final data = await request.get('$baseUrl/threads/replies/$threadId/');
    return (data as List).map((e) => rm.Reply.fromJson(e)).toList();
  }

  Future<Map<String, dynamic>> likeReply(String replyId) async {
    final res = await request.post('$baseUrl/threads/like-reply/$replyId/', {});
    return Map<String, dynamic>.from(res);
  }

  Future<Map<String, dynamic>> addReply(String threadId, String content) async {
    final res = await request.post(
      '$baseUrl/threads/create-reply-ajax/$threadId/',
      {'content': content},
    );
    return Map<String, dynamic>.from(res);
  }

  // ini kamu sudah punya: dipakai untuk tombol delete UI / canDelete
  Future<String> fetchCurrentUsername() async {
    final data = await request.get('$baseUrl/accounts/profile-detail/');
    // sesuaikan kalau struktur JSON-mu beda
    return (data['username'] ?? '').toString();
  }
}
