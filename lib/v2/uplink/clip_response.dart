class ClipResponse {
  final String id;
  final Uri url;
  final Uri embedUrl;
  final int broadcasterId;
  final String broadcasterName;
  final int creatorId;
  final String creatorName;
  final int videoId;
  final int gameId;
  final String language;
  final String title;
  final int viewCount;
  final DateTime createdAt;
  final Uri thumbnailUrl;
  final Duration duration;
  final int vodOffset;
  final bool isFeatured;

  ClipResponse({
    required this.id,
    required this.url,
    required this.embedUrl,
    required this.broadcasterId,
    required this.broadcasterName,
    required this.creatorId,
    required this.creatorName,
    required this.videoId,
    required this.gameId,
    required this.language,
    required this.title,
    required this.viewCount,
    required this.createdAt,
    required this.thumbnailUrl,
    required this.duration,
    required this.vodOffset,
    required this.isFeatured,
  });

  ClipResponse.fromJson(dynamic data)
      : id = data['id'],
        url = Uri.parse(data['url']),
        embedUrl = Uri.parse(data['embed_url']),
        broadcasterId = data['broadcaster_id'],
        broadcasterName = data['broadcaster_name'],
        creatorId = data['creator_id'],
        creatorName = data['creator_name'],
        videoId = data['video_id'],
        gameId = data['game_id'],
        language = data['language'],
        title = data['title'],
        viewCount = data['view_count'],
        createdAt = data['created_at'],
        thumbnailUrl = Uri.parse(data['thumbnail_url']),
        duration = Duration(milliseconds: data['duration'] * 1000),
        vodOffset = data['vod_offset'],
        isFeatured = data['is_featured'];
}
