class StreamResponse {
  final String id;
  final String userId;
  final String userLogin;
  final String userName;
  final String gameId;
  final String gameName;
  final String type;
  final String title;
  final int viewerCount;
  final DateTime startedAt;
  final String language;
  final Uri thumbnailUrl;
  final List<String> tagIds;
  final List<String> tags;
  final bool isMature;

  StreamResponse({
    required this.id,
    required this.userId,
    required this.userLogin,
    required this.userName,
    required this.gameId,
    required this.gameName,
    required this.type,
    required this.title,
    required this.viewerCount,
    required this.startedAt,
    required this.language,
    required this.thumbnailUrl,
    required this.tagIds,
    required this.tags,
    required this.isMature,
  });

  StreamResponse.fromJson(dynamic data)
      : id = data['id'],
        userId = data['user_id'],
        userLogin = data['user_login'],
        userName = data['user_name'],
        gameId = data['game_id'],
        gameName = data['game_name'],
        type = data['type'],
        title = data['title'],
        viewerCount = data['viewer_count'],
        startedAt = DateTime.parse(data['started_at']),
        language = data['language'],
        thumbnailUrl = Uri.parse(data['thumbnail_url']),
        tagIds = List<String>.from(data['tag_ids']),
        tags = List<String>.from(data['tags']),
        isMature = data['is_mature'];
}
