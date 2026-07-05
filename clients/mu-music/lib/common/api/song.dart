/*
 * @Author: 新西兰的肉夹馍
 * @Date: 2025-09-24 12:44:19
 * @LastEditTime: 2025-10-01 23:19:43
 * @FilePath: /mu-music/lib/common/api/song.dart
 * @Description: 歌曲相关api
 * 在这个虚拟的空间里，我试图捕捉真实的自我，与世界分享。
 */
import 'package:mu_music/common/index.dart';

class SongApi {
  static const String song = '/song/url/v1';
  static const String lyric = '/lyric/new';
  static const String recentPlay = '/scrobble';
  static const String songDetail = '/song/detail';

  // 获取歌曲链接
  static Future<Song> getSong(int id, {String level = 'exhigh'}) async {
    return getSongById(id.toString(), level: level);
  }

  static Future<Song> getSongById(String id, {String level = 'exhigh'}) async {
    final track = await NasMusicApi.getTrack(id);
    return Song.fromJson({
      'code': 200,
      'data': [
        {
          'id': track['id'],
          'url': track['url'],
          'level': level,
          'type': track['fileFormat'],
          'size': track['fileSize'],
          'time': track['dt'],
        }
      ],
    });
  }

  // 获取歌词
  static Future<Lyric> getLyric(int id) async {
    return getLyricById(id.toString());
  }

  static Future<Lyric> getLyricById(String id) async {
    final track = await NasMusicApi.getTrack(id);
    return Lyric.fromJson({
      'code': 200,
      'lrc': {
        'lyric': track['lyrics'] ?? '',
      },
    });
  }

  // 添加到最近播放
  static Future<Scrobble> addToRecentPlay(int id) async {
    await NasMusicApi.notifyPlay(id.toString());
    return Scrobble.fromJson({
      'code': 200,
      'data': 'ok',
      'message': '播放状态已同步',
    });
  }

  // 根据ID获取歌曲详情
  static Future<Songdetail> getSongDetail(String ids) async {
    final songs = <Map<String, dynamic>>[];
    for (final id in ids.split(',')) {
      final trimmed = id.trim();
      if (trimmed.isEmpty) continue;
      songs.add(await NasMusicApi.getTrack(trimmed));
    }
    return Songdetail.fromJson({
      'code': 200,
      'songs': songs,
      'privileges': [],
    });
  }
}
