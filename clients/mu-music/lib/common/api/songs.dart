/*
 * @Author: 新西兰的肉夹馍
 * @Date: 2025-09-25 15:04:15
 * @LastEditTime: 2025-12-15 09:12:10
 * @FilePath: /mu-music/lib/common/api/songs.dart
 * @Description:  歌曲api
 * 在这个虚拟的空间里，我试图捕捉真实的自我，与世界分享。
 */
import 'package:mu_music/common/index.dart';

class SongsApi {
  static const String playList = '/playlist/detail';
  // 获取雷达歌单 3136952023-私人雷达 5320167908-时光雷达 5300458264-新歌雷达
  static Future<Playlist> getPlayList(dynamic id) async {
    final playlist = await NasMusicApi.getPlaylist(id.toString());
    return Playlist.fromJson({
      'code': 200,
      'playlist': playlist,
    });
  }

  static const String personalized = '/personalized';
  // 获取个性化推荐歌单
  static Future<Personalized> getPersonalized({int limit = 6}) async {
    final playlists = await NasMusicApi.listPlaylists(limit: limit);
    return Personalized.fromJson({
      'hasTaste': true,
      'code': 200,
      'category': 0,
      'result': playlists,
    });
  }

  static const String singers = '/top/artists';
  // 获取热门歌手
  static Future<Singers> getHotSingers({int limit = 6, int offset = 0}) async {
    final tracks = await NasMusicApi.listTracks(limit: limit * 4, offset: offset);
    final artistsByName = <String, Map<String, dynamic>>{};
    for (final track in tracks) {
      final artists = track['ar'] is List ? track['ar'] as List : <dynamic>[];
      final coverUrl = track['al']?['picUrl']?.toString() ?? '';
      for (final artist in artists) {
        if (artist is! Map) continue;
        final name = artist['name']?.toString() ?? '';
        if (name.isEmpty || artistsByName.containsKey(name)) continue;
        artistsByName[name] = {
          'id': name,
          'name': name,
          'picUrl': coverUrl,
          'musicSize': 1,
          'albumSize': 1,
        };
      }
    }
    return Singers.fromJson({
      'code': 200,
      'more': tracks.length >= limit * 4,
      'artists': artistsByName.values.take(limit).toList(),
    });
  }

  static const String singerSongs = '/artist/songs';
  // 根据歌手ID获取歌手的歌曲
  static Future<Songersing> getSongsBySinger(
      dynamic id, int limit, int offset) async {
    final tracks = await NasMusicApi.listTracks(
      keyword: id.toString(),
      limit: limit,
      offset: offset,
    );
    return Songersing.fromJson({
      'code': 200,
      'songs': tracks,
      'more': tracks.length == limit,
      'total': tracks.length,
    });
  }

  static const String topPlayList = '/top/playlist/highquality';
  // 获取热门歌单
  static Future<Topplaylist> getTopPlayList(
      int id, int limit, int before) async {
    final playlists = await NasMusicApi.listPlaylists(
      limit: limit,
      offset: before,
    );
    return Topplaylist.fromJson({
      'code': 200,
      'playlists': playlists,
      'more': playlists.length == limit,
      'lasttime': before + playlists.length,
      'total': before + playlists.length,
    });
  }
}
