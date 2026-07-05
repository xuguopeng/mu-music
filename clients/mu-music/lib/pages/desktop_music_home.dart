import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:mu_music/common/index.dart';

class DesktopMusicHome extends StatefulWidget {
  DesktopMusicHome({super.key});

  @override
  State<DesktopMusicHome> createState() => _DesktopMusicHomeState();
}

class _DesktopMusicHomeState extends State<DesktopMusicHome> {
  final TextEditingController _searchController = TextEditingController();
  final GetStorage _storage = GetStorage();
  final PlaylistStore _playlistStore = Get.find<PlaylistStore>();
  final GlobalMusicController _musicController =
      Get.find<GlobalMusicController>();
  final GlobalPlayerStore _globalPlayerStore = Get.find<GlobalPlayerStore>();

  List<Map<String, dynamic>> _tracks = [];
  List<Map<String, dynamic>> _radioEpisodes = [];
  Map<String, dynamic>? _radioStatus;
  Map<String, dynamic>? _dailyRadioStatus;
  Set<String> _favoriteTrackIds = {};
  List<String> _playHistoryIds = [];
  _DesktopMusicViewMode _viewMode = _DesktopMusicViewMode.tracks;
  String? _selectedArtistName;
  bool _loading = true;
  bool _radioLoading = false;
  bool _radioGenerating = false;
  bool _dailyRadioGenerating = false;
  String? _error;
  String? _radioError;
  String? _hoveredTrackId;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
    _loadPlaybackHistory();
    _loadTracks();
    _loadRadioStatus();
    _loadRadioEpisodes();
    _loadDailyRadioStatus();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadTracks([String keyword = '']) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await NasMusicApi.login();
      final tracks = await NasMusicApi.listTracks(
        keyword: keyword,
        limit: 80,
      );
      if (!mounted) return;
      setState(() {
        _tracks = tracks;
        _loading = false;
      });
      if (_globalPlayerStore.currentTrack == null && tracks.isNotEmpty) {
        _globalPlayerStore.setCurrentTrack(tracks.first);
      }
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString();
        _loading = false;
      });
    }
  }

  void _loadFavorites() {
    final stored =
        _storage.read<List<dynamic>>('desktop_favorite_track_ids') ?? [];
    _favoriteTrackIds = stored.map((item) => item.toString()).toSet();
  }

  void _loadPlaybackHistory() {
    final stored =
        _storage.read<List<dynamic>>('desktop_play_history_ids') ?? [];
    _playHistoryIds = stored.map((item) => item.toString()).toList();
  }

  void _toggleFavorite(Map<String, dynamic> track) {
    final id = track['id']?.toString() ?? '';
    if (id.isEmpty) return;
    setState(() {
      if (_favoriteTrackIds.contains(id)) {
        _favoriteTrackIds.remove(id);
      } else {
        _favoriteTrackIds.add(id);
      }
    });
    _storage.write('desktop_favorite_track_ids', _favoriteTrackIds.toList());
  }

  Future<void> _playTrack(Map<String, dynamic> track, int index) async {
    final playlist = _visibleTracks();
    _playlistStore.setCurrentPlaylist(playlist, startIndex: index);
    _globalPlayerStore.setCurrentTrack(track);
    _addPlaybackHistory(track);
    await _musicController.initMusicData(track);
  }

  void _addPlaybackHistory(Map<String, dynamic> track) {
    final id = track['id']?.toString() ?? '';
    if (id.isEmpty || id.startsWith('radio_')) return;
    setState(() {
      _playHistoryIds.remove(id);
      _playHistoryIds.insert(0, id);
      if (_playHistoryIds.length > 80) {
        _playHistoryIds = _playHistoryIds.take(80).toList();
      }
    });
    _storage.write('desktop_play_history_ids', _playHistoryIds);
  }

  Future<void> _loadRadioEpisodes() async {
    setState(() {
      _radioLoading = true;
      _radioError = null;
    });
    try {
      final episodes = await NasMusicApi.listRadioEpisodes();
      if (!mounted) return;
      setState(() {
        _radioEpisodes = episodes;
        _radioLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _radioError = error.toString();
        _radioLoading = false;
      });
    }
  }

  Future<void> _loadRadioStatus() async {
    try {
      final status = await NasMusicApi.getRadioStatus();
      if (!mounted) return;
      setState(() => _radioStatus = status);
    } catch (_) {
      if (!mounted) return;
      setState(() => _radioStatus = null);
    }
  }

  Future<void> _loadDailyRadioStatus() async {
    try {
      final status = await NasMusicApi.getDailyRadioStatus();
      if (!mounted) return;
      setState(() => _dailyRadioStatus = status);
    } catch (_) {
      if (!mounted) return;
      setState(() => _dailyRadioStatus = null);
    }
  }

  Future<void> _generateRadioEpisode() async {
    final seedTracks = _visibleTracks().isNotEmpty ? _visibleTracks() : _tracks;
    final trackIds = seedTracks
        .map((track) => track['id']?.toString() ?? '')
        .where((id) => id.isNotEmpty)
        .take(10)
        .toList();
    setState(() {
      _radioGenerating = true;
      _radioError = null;
    });
    try {
      final result = await NasMusicApi.createRadioJob(trackIds: trackIds);
      final episode = result['episode'];
      if (!mounted) return;
      if (episode is Map) {
        setState(() {
          _radioEpisodes = [
            Map<String, dynamic>.from(episode),
            ..._radioEpisodes,
          ];
        });
      }
      await _loadRadioStatus();
      await _loadRadioEpisodes();
    } catch (error) {
      if (!mounted) return;
      setState(() => _radioError = error.toString());
    } finally {
      if (mounted) {
        setState(() => _radioGenerating = false);
      }
    }
  }

  Future<void> _runDailyRadioNow() async {
    setState(() {
      _dailyRadioGenerating = true;
      _radioError = null;
    });
    try {
      final result = await NasMusicApi.runDailyRadioNow();
      final episode = result['episode'];
      if (!mounted) return;
      if (episode is Map) {
        setState(() {
          _radioEpisodes = [
            Map<String, dynamic>.from(episode),
            ..._radioEpisodes,
          ];
        });
      }
      await _loadDailyRadioStatus();
      await _loadRadioStatus();
      await _loadRadioEpisodes();
    } catch (error) {
      if (!mounted) return;
      setState(() => _radioError = error.toString());
    } finally {
      if (mounted) {
        setState(() => _dailyRadioGenerating = false);
      }
    }
  }

  Future<void> _playRadioEpisode(Map<String, dynamic> episode) async {
    final playlist = NasMusicApi.normalizeRadioEpisodePlaylist(episode);
    if (playlist.isEmpty) return;
    final track = playlist.first;
    _playlistStore.setCurrentPlaylist(playlist, startIndex: 0);
    _globalPlayerStore.setCurrentTrack(track);
    await _musicController.initMusicData(track);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBg,
      body: Stack(
        children: [
          Positioned.fill(child: _StarFieldBackground()),
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      _buildReferenceSidebar(),
                      Expanded(child: _buildReferenceWorkspace()),
                    ],
                  ),
                ),
                _buildReferencePlayerBar(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReferenceSidebar() {
    return Container(
      width: 228,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: AppColors.isDark ? 0.48 : 0.06),
        border: Border(right: BorderSide(color: AppColors.borderColor)),
      ),
      padding: EdgeInsets.fromLTRB(28, 30, 18, 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '沐音',
            style: TextStyle(
              color: AppColors.primaryBtn,
              fontSize: 26,
              fontWeight: FontWeight.w800,
              letterSpacing: 0,
            ),
          ),
          SizedBox(height: 34),
          _ReferenceNavItem(
            active: _viewMode == _DesktopMusicViewMode.tracks,
            icon: Icons.music_note_outlined,
            label: '音乐库',
            onTap: () => setState(() {
              _viewMode = _DesktopMusicViewMode.tracks;
              _selectedArtistName = null;
            }),
          ),
          _ReferenceNavItem(
            active: _viewMode == _DesktopMusicViewMode.radio,
            icon: Icons.radio_outlined,
            label: '今日电台',
            onTap: () => setState(() {
              _viewMode = _DesktopMusicViewMode.radio;
              _selectedArtistName = null;
            }),
          ),
          _ReferenceNavItem(
            active: _viewMode == _DesktopMusicViewMode.artists,
            icon: Icons.person_outline,
            label: '歌手',
            onTap: () => setState(() {
              _viewMode = _DesktopMusicViewMode.artists;
              _selectedArtistName = null;
            }),
          ),
          _ReferenceNavItem(
            active: false,
            icon: Icons.album_outlined,
            label: '专辑',
            onTap: () => setState(() {
              _viewMode = _DesktopMusicViewMode.tracks;
              _selectedArtistName = null;
            }),
          ),
          _ReferenceNavItem(
            active: _viewMode == _DesktopMusicViewMode.tracks,
            icon: Icons.queue_music_outlined,
            label: '歌曲',
            onTap: () => setState(() {
              _viewMode = _DesktopMusicViewMode.tracks;
              _selectedArtistName = null;
            }),
          ),
          _ReferenceNavItem(
            active: _viewMode == _DesktopMusicViewMode.favorites,
            icon: Icons.favorite_border,
            label: '喜欢的音乐',
            onTap: () => setState(() {
              _viewMode = _DesktopMusicViewMode.favorites;
              _selectedArtistName = null;
            }),
          ),
          SizedBox(height: 20),
          Divider(color: AppColors.borderColor, height: 1),
          SizedBox(height: 18),
          _ReferenceNavItem(
            active: _viewMode == _DesktopMusicViewMode.history,
            icon: Icons.history,
            label: '播放记录',
            onTap: () => setState(() {
              _viewMode = _DesktopMusicViewMode.history;
              _selectedArtistName = null;
            }),
          ),
          SizedBox(height: 20),
          Divider(color: AppColors.borderColor, height: 1),
          SizedBox(height: 18),
          Padding(
            padding: EdgeInsets.only(left: 2, bottom: 10),
            child: Text(
              '播放 NAS',
              style: TextStyle(
                color: AppColors.secondaryText,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          _ReferenceNavItem(
            active: false,
            icon: Icons.storage_outlined,
            label: 'NAS 音乐库',
            onTap: () => setState(() {
              _viewMode = _DesktopMusicViewMode.tracks;
              _selectedArtistName = null;
            }),
          ),
          _ReferenceNavItem(
            active: false,
            icon: Icons.file_download_outlined,
            label: '本地导入',
            onTap: () {},
          ),
          _ReferenceNavItem(
            active: false,
            icon: Icons.sd_storage_outlined,
            label: '外接存储',
            onTap: () {},
          ),
          Spacer(),
          _ReferenceNavItem(
            active: false,
            icon: Icons.settings_outlined,
            label: '设置',
            onTap: () => Get.find<ThemeStore>().toggleTheme(),
          ),
        ],
      ),
    );
  }

  Widget _buildReferenceWorkspace() {
    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: EdgeInsets.fromLTRB(34, 30, 24, 0),
            child: Column(
              children: [
                _buildReferenceToolbar(),
                SizedBox(height: 34),
                _buildReferenceTabs(),
                SizedBox(height: 18),
                Expanded(child: _buildReferenceCenter()),
              ],
            ),
          ),
        ),
        Container(
          width: 330,
          padding: EdgeInsets.fromLTRB(0, 92, 22, 0),
          decoration: BoxDecoration(
            border: Border(left: BorderSide(color: AppColors.borderColor)),
          ),
          child: _buildReferenceRightRail(),
        ),
      ],
    );
  }

  Widget _buildReferenceToolbar() {
    return Row(
      children: [
        SizedBox(
          width: 360,
          child: _buildReferenceSearchField(),
        ),
        Spacer(),
        _ReferenceToolbarAction(
          icon: Icons.file_download_outlined,
          label: '导入音乐',
          onTap: () {},
        ),
        SizedBox(width: 18),
        _ReferenceToolbarAction(
          icon: Icons.refresh,
          label: '刷新',
          onTap: () => _loadTracks(_searchController.text),
        ),
        SizedBox(width: 16),
        IconButton(
          tooltip: '切换主题',
          onPressed: () => Get.find<ThemeStore>().toggleTheme(),
          icon: Icon(
            AppColors.isDark ? Icons.light_mode_outlined : Icons.dark_mode,
            color: AppColors.secondaryText,
            size: 20,
          ),
        ),
        SizedBox(width: 8),
        Icon(Icons.remove, color: AppColors.secondaryText, size: 20),
        SizedBox(width: 18),
        Icon(Icons.crop_square, color: AppColors.secondaryText, size: 16),
        SizedBox(width: 18),
        Icon(Icons.close, color: AppColors.secondaryText, size: 20),
      ],
    );
  }

  Widget _buildReferenceSearchField() {
    return Container(
      height: 42,
      decoration: BoxDecoration(
        color: AppColors.navigationBg
            .withValues(alpha: AppColors.isDark ? 0.5 : 0.82),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.borderColor),
        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withValues(alpha: AppColors.isDark ? 0.24 : 0.04),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onSubmitted: _loadTracks,
        style: TextStyle(color: AppColors.primaryText, fontSize: 13),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: '搜索歌曲、专辑、歌手、歌词...',
          hintStyle: TextStyle(color: AppColors.secondaryText, fontSize: 13),
          prefixIcon: Icon(
            Icons.search,
            color: AppColors.secondaryText,
            size: 20,
          ),
          contentPadding: EdgeInsets.only(top: 10),
        ),
      ),
    );
  }

  Widget _buildReferenceTabs() {
    final tabs = [
      ('音乐库', _DesktopMusicViewMode.tracks),
      ('专辑', _DesktopMusicViewMode.tracks),
      ('歌手', _DesktopMusicViewMode.artists),
      ('文件夹', _DesktopMusicViewMode.tracks),
    ];
    return Container(
      height: 44,
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.borderColor)),
      ),
      child: Row(
        children: [
          for (final tab in tabs)
            _ReferenceTab(
              label: tab.$1,
              active: (_viewMode == tab.$2 &&
                      (tab.$1 == '音乐库' || tab.$1 == '歌手')) ||
                  (_viewMode == _DesktopMusicViewMode.favorites &&
                      tab.$1 == '音乐库') ||
                  (_viewMode == _DesktopMusicViewMode.history &&
                      tab.$1 == '音乐库') ||
                  (_viewMode == _DesktopMusicViewMode.radio && tab.$1 == '音乐库'),
              onTap: () => setState(() {
                _viewMode = tab.$2;
                _selectedArtistName = null;
              }),
            ),
        ],
      ),
    );
  }

  Widget _buildReferenceCenter() {
    if (_viewMode == _DesktopMusicViewMode.radio) {
      return _buildReferenceRadioList();
    }
    if (_loading) return _buildLoadingState('音乐加载中...');
    if (_error != null) return _buildError();
    if (_viewMode == _DesktopMusicViewMode.artists &&
        _selectedArtistName == null) {
      return _buildReferenceArtistGrid();
    }
    final tracks = _visibleTracks();
    return Column(
      children: [
        _buildReferenceActions(tracks),
        SizedBox(height: 22),
        _buildReferenceTableHeader(),
        Expanded(child: _buildReferenceTrackTable(tracks)),
        Padding(
          padding: EdgeInsets.only(top: 12, bottom: 10),
          child: Text(
            '共 ${tracks.length} 首歌曲',
            style: TextStyle(
              color: AppColors.secondaryText,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReferenceActions(List<Map<String, dynamic>> tracks) {
    return Row(
      children: [
        _ReferencePrimaryButton(
          icon: Icons.play_arrow,
          label: '播放全部',
          onTap: tracks.isEmpty ? null : () => _playTrack(tracks.first, 0),
        ),
        SizedBox(width: 12),
        _ReferenceGhostButton(
          icon: Icons.shuffle,
          label: '随机播放',
          onTap: tracks.isEmpty
              ? null
              : () {
                  final index =
                      DateTime.now().millisecondsSinceEpoch % tracks.length;
                  _playTrack(tracks[index], index);
                },
        ),
        SizedBox(width: 10),
        _ReferenceIconButton(icon: Icons.more_horiz, onTap: () {}),
      ],
    );
  }

  Widget _buildReferenceTableHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 18),
      child: Row(
        children: [
          _tableCell('#', 42, header: true),
          Expanded(flex: 34, child: _tableText('歌曲', header: true)),
          Expanded(flex: 22, child: _tableText('歌手', header: true)),
          Expanded(flex: 26, child: _tableText('专辑', header: true)),
          Expanded(flex: 16, child: _tableText('时长', header: true)),
          Expanded(flex: 20, child: _tableText('添加时间', header: true)),
          SizedBox(width: 44),
        ],
      ),
    );
  }

  Widget _buildReferenceTrackTable(List<Map<String, dynamic>> tracks) {
    if (tracks.isEmpty) {
      return Center(
        child: Text(
          _emptyText(),
          style: TextStyle(color: AppColors.secondaryText),
        ),
      );
    }
    return ListView.builder(
      padding: EdgeInsets.only(top: 10, bottom: 8),
      itemCount: tracks.length,
      itemBuilder: (context, index) {
        final track = tracks[index];
        return Obx(() {
          final active = _globalPlayerStore.currentTrack?['id'] == track['id'];
          return _buildReferenceTrackRow(track, index, active);
        });
      },
    );
  }

  Widget _buildReferenceTrackRow(
    Map<String, dynamic> track,
    int index,
    bool active,
  ) {
    final id = track['id']?.toString() ?? '';
    final hovered = _hoveredTrackId == id;
    final highlighted = active || hovered;
    final favorite = _favoriteTrackIds.contains(id);
    final addedDay =
        (18 - (index ~/ 3)).clamp(1, 28).toString().padLeft(2, '0');
    return MouseRegion(
      onEnter: (_) => setState(() => _hoveredTrackId = id),
      onExit: (_) => setState(() => _hoveredTrackId = null),
      child: InkWell(
        borderRadius: BorderRadius.circular(6),
        onTap: () => _playTrack(track, index),
        child: AnimatedContainer(
          duration: Duration(milliseconds: 160),
          height: 52,
          margin: EdgeInsets.only(bottom: 2),
          padding: EdgeInsets.symmetric(horizontal: 18),
          decoration: BoxDecoration(
            color: highlighted
                ? AppColors.primaryBtn
                    .withValues(alpha: AppColors.isDark ? 0.10 : 0.08)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            border: Border(
              bottom: BorderSide(
                color: AppColors.borderColor.withValues(alpha: 0.72),
              ),
            ),
            boxShadow: highlighted
                ? [
                    BoxShadow(
                      color: AppColors.primaryBtn.withValues(alpha: 0.22),
                      blurRadius: 24,
                      offset: Offset(0, 0),
                    ),
                  ]
                : [],
          ),
          child: Row(
            children: [
              SizedBox(
                width: 42,
                child: highlighted
                    ? Icon(
                        active ? Icons.volume_up_outlined : Icons.play_arrow,
                        color: AppColors.primaryBtn,
                        size: 20,
                      )
                    : Text(
                        '${index + 1}',
                        style: TextStyle(
                          color: AppColors.secondaryText,
                          fontSize: 13,
                        ),
                      ),
              ),
              Expanded(
                flex: 34,
                child: _tableText(
                  track['name']?.toString() ?? '未知歌曲',
                  active: highlighted,
                ),
              ),
              Expanded(
                flex: 22,
                child: _tableText(_artistName(track), active: highlighted),
              ),
              Expanded(
                flex: 26,
                child: _tableText(_albumField(track, 'name', fallback: '未知专辑')),
              ),
              Expanded(
                flex: 16,
                child: _tableText(_formatTrackDuration(track), numeric: true),
              ),
              Expanded(
                flex: 20,
                child: _tableText('2024-06-$addedDay'),
              ),
              SizedBox(
                width: 44,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      tooltip: favorite ? '取消喜欢' : '设为喜欢',
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints.tight(Size(30, 30)),
                      onPressed: () => _toggleFavorite(track),
                      icon: Icon(
                        favorite ? Icons.favorite : Icons.favorite_border,
                        color: favorite
                            ? AppColors.primaryBtn
                            : AppColors.secondaryText,
                        size: 19,
                      ),
                    ),
                    if (highlighted)
                      Icon(Icons.more_horiz,
                          color: AppColors.primaryText, size: 18),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReferenceArtistGrid() {
    final groups = _artistGroups();
    final entries = groups.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    if (entries.isEmpty) {
      return Center(
        child: Text('暂无歌手', style: TextStyle(color: AppColors.secondaryText)),
      );
    }
    return GridView.builder(
      padding: EdgeInsets.only(top: 4, bottom: 18),
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 260,
        mainAxisExtent: 86,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
      ),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        final firstTrack = entry.value.first;
        return InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => setState(() => _selectedArtistName = entry.key),
          child: Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.navigationBg.withValues(alpha: 0.42),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderColor),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(9),
                  child: NetImage(
                    _albumField(firstTrack, 'picUrl'),
                    width: 52,
                    height: 52,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        entry.key,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppColors.primaryText,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '${entry.value.length} 首歌曲',
                        style: TextStyle(
                          color: AppColors.secondaryText,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: AppColors.secondaryText),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildReferenceRadioList() {
    return Column(
      children: [
        _buildReferenceActions(_tracks),
        SizedBox(height: 18),
        Container(
          padding: EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.primaryBtn.withValues(alpha: 0.16),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.primaryBtn.withValues(alpha: 0.28),
            ),
          ),
          child: Row(
            children: [
              Icon(Icons.radio_outlined, color: AppColors.primaryBtn, size: 36),
              SizedBox(width: 14),
              Expanded(
                child: Text(
                  '${_dailyRadioSummary()} 生成后按“开场语音、推荐歌曲、收尾语音”顺序加入播放队列。',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.secondaryText,
                    fontSize: 13,
                    height: 1.45,
                  ),
                ),
              ),
              SizedBox(width: 14),
              _ReferencePrimaryButton(
                icon: Icons.wb_sunny_outlined,
                label: _dailyRadioGenerating ? '生成中' : '今日电台',
                onTap: _dailyRadioGenerating ? null : _runDailyRadioNow,
              ),
            ],
          ),
        ),
        if (_radioError != null)
          Padding(
            padding: EdgeInsets.only(top: 12),
            child: Text(
              _radioError!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.redAccent, fontSize: 12),
            ),
          ),
        SizedBox(height: 18),
        Expanded(
          child: _radioLoading
              ? _buildLoadingState('电台加载中...')
              : _radioEpisodes.isEmpty
                  ? Center(
                      child: Text(
                        '还没有生成过电台',
                        style: TextStyle(color: AppColors.secondaryText),
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: _radioEpisodes.length,
                      itemBuilder: (context, index) {
                        final episode = _radioEpisodes[index];
                        return _RadioEpisodeItem(
                          episode: episode,
                          onTap: () => _playRadioEpisode(episode),
                        );
                      },
                    ),
        ),
      ],
    );
  }

  Widget _buildReferenceRightRail() {
    return Column(
      children: [
        _buildReferenceTodayRadioCard(),
        SizedBox(height: 12),
        Expanded(child: _buildReferenceRecentCard()),
        SizedBox(height: 12),
        _buildReferenceFavoriteCard(),
      ],
    );
  }

  Widget _buildReferenceTodayRadioCard() {
    final generating = _dailyRadioGenerating || _radioGenerating;
    final latest = _radioEpisodes.isNotEmpty ? _radioEpisodes.first : null;
    final title = latest?['title']?.toString() ?? '轻柔治愈的音乐';
    final summary =
        latest?['summary']?.toString() ?? '根据你的喜好生成中，包含华语、流行、夜晚等多种风格';
    return _ReferencePanel(
      child: Padding(
        padding: EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '今日电台',
                    style: TextStyle(
                      color: AppColors.primaryText,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Text(
                  generating ? '生成中 00:18' : '已就绪',
                  style: TextStyle(
                    color: generating
                        ? AppColors.primaryBtn
                        : AppColors.secondaryText,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Icon(Icons.graphic_eq, color: AppColors.primaryBtn, size: 58),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppColors.primaryText,
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: 7),
                      Text(
                        summary,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppColors.secondaryText,
                          fontSize: 12,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _ReferenceGhostButton(
                    icon: generating ? Icons.pause : Icons.wb_sunny_outlined,
                    label: generating ? '生成中' : '今日电台',
                    onTap: generating ? null : _runDailyRadioNow,
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: _ReferenceGhostButton(
                    icon: Icons.skip_next,
                    label: '换一批',
                    onTap: _radioGenerating ? null : _generateRadioEpisode,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReferenceRecentCard() {
    final tracks = _playHistoryTracks().take(5).toList();
    return _ReferencePanel(
      child: Padding(
        padding: EdgeInsets.fromLTRB(18, 16, 18, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '最近播放',
                    style: TextStyle(
                      color: AppColors.primaryText,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => setState(() {
                    _viewMode = _DesktopMusicViewMode.history;
                    _selectedArtistName = null;
                  }),
                  child: Text('清空', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
            SizedBox(height: 12),
            Expanded(
              child: tracks.isEmpty
                  ? Center(
                      child: Text(
                        '暂无播放记录',
                        style: TextStyle(color: AppColors.secondaryText),
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: tracks.length,
                      itemBuilder: (context, index) {
                        final track = tracks[index];
                        return _RightRailTrack(
                          track: track,
                          duration: _formatTrackDuration(track),
                          onTap: () =>
                              _playTrack(track, _tracks.indexOf(track)),
                          artistName: _artistName(track),
                          coverUrl: _albumField(track, 'picUrl'),
                        );
                      },
                    ),
            ),
            Center(
              child: TextButton(
                onPressed: () => setState(() {
                  _viewMode = _DesktopMusicViewMode.history;
                  _selectedArtistName = null;
                }),
                child: Text('查看全部播放记录'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReferenceFavoriteCard() {
    final tracks = _tracks
        .where((track) => _favoriteTrackIds.contains(track['id']?.toString()))
        .take(4)
        .toList();
    return _ReferencePanel(
      child: Padding(
        padding: EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(Icons.favorite, color: AppColors.primaryBtn, size: 19),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '我喜欢的音乐  ${_favoriteTrackIds.length} 首',
                    style: TextStyle(
                      color: AppColors.primaryText,
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              children: [
                for (final track in tracks)
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(right: 8),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: NetImage(
                          _albumField(track, 'picUrl'),
                          height: 48,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                if (tracks.isEmpty)
                  Expanded(
                    child: Text(
                      '还没有喜欢的音乐',
                      style: TextStyle(
                        color: AppColors.secondaryText,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 8),
            Center(
              child: TextButton(
                onPressed: () => setState(() {
                  _viewMode = _DesktopMusicViewMode.favorites;
                  _selectedArtistName = null;
                }),
                child: Text('查看全部'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReferencePlayerBar() {
    return Obx(() {
      final track = _globalPlayerStore.currentTrack;
      return Container(
        height: 120,
        margin: EdgeInsets.fromLTRB(14, 0, 14, 12),
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.navigationBg
              .withValues(alpha: AppColors.isDark ? 0.72 : 0.9),
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: AppColors.borderColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black
                  .withValues(alpha: AppColors.isDark ? 0.38 : 0.08),
              blurRadius: 24,
              offset: Offset(0, -8),
            ),
          ],
        ),
        child: track == null
            ? Center(
                child: Text(
                  '选择一首歌曲开始播放',
                  style: TextStyle(color: AppColors.secondaryText),
                ),
              )
            : Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: NetImage(
                      _albumField(track, 'picUrl'),
                      width: 78,
                      height: 78,
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(width: 20),
                  SizedBox(
                    width: 240,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          track['name']?.toString() ?? '未知歌曲',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: AppColors.primaryText,
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '${_artistName(track)}  ·  ${_albumField(track, 'name', fallback: '未知专辑')}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: AppColors.secondaryText,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: '喜欢',
                    onPressed: () => _toggleFavorite(track),
                    icon: Icon(
                      _favoriteTrackIds.contains(track['id']?.toString())
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: AppColors.primaryBtn,
                    ),
                  ),
                  IconButton(
                    tooltip: '更多',
                    onPressed: () {},
                    icon: Icon(Icons.more_horiz, color: AppColors.primaryText),
                  ),
                  Expanded(
                    child: GetBuilder<GlobalMusicController>(
                      builder: (controller) {
                        final total = controller.totalDuration > 0
                            ? controller.totalDuration
                            : _trackDurationMilliseconds(track);
                        final current = controller.currentPosition
                            .clamp(0, math.max(total, 1))
                            .toInt();
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  tooltip: '播放模式',
                                  onPressed: _playlistStore.togglePlayMode,
                                  icon: Icon(
                                    _playModeIcon(),
                                    color: AppColors.primaryText,
                                  ),
                                ),
                                SizedBox(width: 14),
                                IconButton(
                                  tooltip: '上一首',
                                  onPressed: _musicController.playPrevious,
                                  icon: Icon(
                                    Icons.skip_previous,
                                    color: AppColors.primaryText,
                                    size: 28,
                                  ),
                                ),
                                SizedBox(width: 16),
                                Container(
                                  width: 52,
                                  height: 52,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.primaryBtn,
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.primaryBtn
                                            .withValues(alpha: 0.34),
                                        blurRadius: 24,
                                      ),
                                    ],
                                  ),
                                  child: IconButton(
                                    tooltip: controller.isPlaying ? '暂停' : '播放',
                                    onPressed: controller.togglePlayPause,
                                    icon: Icon(
                                      controller.isPlaying
                                          ? Icons.pause
                                          : Icons.play_arrow,
                                      color: Colors.white,
                                      size: 28,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 16),
                                IconButton(
                                  tooltip: '下一首',
                                  onPressed: _musicController.playNext,
                                  icon: Icon(
                                    Icons.skip_next,
                                    color: AppColors.primaryText,
                                    size: 28,
                                  ),
                                ),
                                SizedBox(width: 14),
                                IconButton(
                                  tooltip: '循环',
                                  onPressed: _playlistStore.togglePlayMode,
                                  icon: Icon(
                                    Icons.repeat,
                                    color: AppColors.primaryText,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Row(
                              children: [
                                Text(
                                  controller.formatDuration(current),
                                  style: TextStyle(
                                    color: AppColors.secondaryText,
                                    fontSize: 12,
                                  ),
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: SliderTheme(
                                    data: SliderTheme.of(context).copyWith(
                                      trackHeight: 3,
                                      thumbShape: RoundSliderThumbShape(
                                        enabledThumbRadius: 6,
                                      ),
                                      overlayShape:
                                          SliderComponentShape.noOverlay,
                                      activeTrackColor: AppColors.primaryBtn,
                                      inactiveTrackColor: AppColors.borderColor,
                                      thumbColor: AppColors.primaryBtn,
                                    ),
                                    child: Slider(
                                      min: 0,
                                      max: math.max(total, 1).toDouble(),
                                      value: current.toDouble(),
                                      onChanged: (value) =>
                                          controller.seekTo(value.round()),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 10),
                                Text(
                                  controller.formatDuration(total),
                                  style: TextStyle(
                                    color: AppColors.secondaryText,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  SizedBox(width: 28),
                  Icon(Icons.volume_up_outlined,
                      color: AppColors.primaryText, size: 22),
                  SizedBox(
                    width: 130,
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        trackHeight: 3,
                        thumbShape:
                            RoundSliderThumbShape(enabledThumbRadius: 6),
                        overlayShape: SliderComponentShape.noOverlay,
                        activeTrackColor: AppColors.primaryBtn,
                        inactiveTrackColor: AppColors.borderColor,
                        thumbColor: AppColors.primaryBtn,
                      ),
                      child: Slider(
                        value: 0.72,
                        onChanged: (_) {},
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: '歌词',
                    onPressed: () {},
                    icon: Icon(Icons.lyrics_outlined,
                        color: AppColors.primaryText, size: 21),
                  ),
                  IconButton(
                    tooltip: '播放队列',
                    onPressed: showPlaylistDialog,
                    icon: Icon(Icons.format_list_bulleted,
                        color: AppColors.primaryText, size: 23),
                  ),
                ],
              ),
      );
    });
  }

  Widget _tableCell(String text, double width, {bool header = false}) {
    return SizedBox(width: width, child: _tableText(text, header: header));
  }

  Widget _tableText(
    String text, {
    bool header = false,
    bool active = false,
    bool numeric = false,
  }) {
    return Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      textAlign: numeric ? TextAlign.left : TextAlign.left,
      style: TextStyle(
        color: header
            ? AppColors.secondaryText
            : active
                ? AppColors.primaryText
                : AppColors.primaryText.withValues(alpha: 0.82),
        fontSize: header ? 12 : 14,
        fontWeight: header ? FontWeight.w700 : FontWeight.w500,
      ),
    );
  }

  List<Map<String, dynamic>> _playHistoryTracks() {
    final byId = {
      for (final track in _tracks) track['id']?.toString() ?? '': track,
    };
    return _playHistoryIds
        .map((id) => byId[id])
        .whereType<Map<String, dynamic>>()
        .toList();
  }

  String _formatTrackDuration(Map<String, dynamic> track) {
    final milliseconds = _trackDurationMilliseconds(track);
    final minutes = (milliseconds ~/ 60000).toString().padLeft(2, '0');
    final seconds = ((milliseconds ~/ 1000) % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  int _trackDurationMilliseconds(Map<String, dynamic> track) {
    final raw = track['dt'] ?? track['duration'] ?? track['durationMs'];
    if (raw is int) return raw > 10000 ? raw : raw * 1000;
    final parsed = int.tryParse(raw?.toString() ?? '') ?? 0;
    return parsed > 10000 ? parsed : parsed * 1000;
  }

  IconData _playModeIcon() {
    switch (_playlistStore.playMode) {
      case 1:
        return Icons.shuffle;
      case 2:
        return Icons.repeat_one;
      default:
        return Icons.repeat;
    }
  }

  Widget _buildTopBar() {
    return Container(
      height: 64,
      color: AppColors.navigationBg,
      padding: EdgeInsets.symmetric(horizontal: 18),
      child: Row(
        children: [
          Text(
            '沐音',
            style: TextStyle(
              color: AppColors.primaryText,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          Spacer(),
          ThemeToggleButton(),
          SizedBox(width: 8),
          IconButton(
            tooltip: '刷新曲库',
            onPressed: () => _loadTracks(_searchController.text),
            icon: Icon(
              Icons.refresh,
              color: AppColors.secondaryText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return Container(
      height: 38,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: TextField(
        controller: _searchController,
        onSubmitted: _loadTracks,
        style: TextStyle(color: AppColors.primaryText, fontSize: 14),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: '搜索歌曲、专辑',
          hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
          prefixIcon:
              Icon(Icons.search, color: AppColors.secondaryText, size: 20),
          suffixIcon: IconButton(
            onPressed: () => _loadTracks(_searchController.text),
            icon: Icon(Icons.arrow_forward,
                color: AppColors.secondaryText, size: 18),
          ),
          contentPadding: EdgeInsets.only(top: 9),
        ),
      ),
    );
  }

  Widget _buildTrackPanel() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.navigationBg.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderColor),
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        children: [
          _buildLibrarySidebar(),
          Expanded(
            child: Column(
              children: [
                _buildLibraryHeader(),
                Expanded(child: _buildLibraryContent()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLibrarySidebar() {
    return Container(
      width: 178,
      decoration: BoxDecoration(
        color: AppColors.appBg,
        border: Border(
          right: BorderSide(color: AppColors.borderColor),
        ),
      ),
      padding: EdgeInsets.fromLTRB(12, 14, 12, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              '音乐库',
              style: TextStyle(
                color: AppColors.primaryText,
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          SizedBox(height: 14),
          _LibraryNavItem(
            active: _viewMode == _DesktopMusicViewMode.tracks,
            icon: Icons.queue_music,
            label: '音乐列表',
            count: _tracks.length,
            onTap: () => setState(() {
              _viewMode = _DesktopMusicViewMode.tracks;
              _selectedArtistName = null;
            }),
          ),
          _LibraryNavItem(
            active: _viewMode == _DesktopMusicViewMode.artists,
            icon: Icons.person_outline,
            label: '歌手列表',
            count: _artistGroups().length,
            onTap: () => setState(() {
              _viewMode = _DesktopMusicViewMode.artists;
            }),
          ),
          _LibraryNavItem(
            active: _viewMode == _DesktopMusicViewMode.favorites,
            icon: Icons.favorite_border,
            label: '喜欢',
            count: _favoriteTrackIds.length,
            onTap: () => setState(() {
              _viewMode = _DesktopMusicViewMode.favorites;
              _selectedArtistName = null;
            }),
          ),
          _LibraryNavItem(
            active: _viewMode == _DesktopMusicViewMode.history,
            icon: Icons.history,
            label: '播放记录',
            count: _playHistoryIds.length,
            onTap: () => setState(() {
              _viewMode = _DesktopMusicViewMode.history;
              _selectedArtistName = null;
            }),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(8, 14, 8, 8),
            child: Text(
              '智能内容',
              style: TextStyle(
                color: AppColors.secondaryText,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          _LibraryNavItem(
            active: _viewMode == _DesktopMusicViewMode.radio,
            icon: Icons.radio,
            label: '今日电台',
            count: _radioEpisodes.length,
            onTap: () => setState(() {
              _viewMode = _DesktopMusicViewMode.radio;
              _selectedArtistName = null;
            }),
          ),
          Spacer(),
          _buildNowPlayingMini(),
        ],
      ),
    );
  }

  Widget _buildLibraryHeader() {
    return Container(
      constraints: BoxConstraints(minHeight: 122),
      padding: EdgeInsets.fromLTRB(18, 16, 18, 14),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.borderColor),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _contentTitle(),
                      style: TextStyle(
                        color: AppColors.primaryText,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      _contentSubtitle(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.secondaryText,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              if (_viewMode == _DesktopMusicViewMode.radio) ...[
                _RadioStatusBadge(status: _radioStatus),
                SizedBox(width: 10),
                IconButton(
                  tooltip: '刷新电台',
                  onPressed: () {
                    _loadRadioStatus();
                    _loadDailyRadioStatus();
                    _loadRadioEpisodes();
                  },
                  icon: Icon(
                    Icons.refresh,
                    color: AppColors.secondaryText,
                    size: 20,
                  ),
                ),
              ],
            ],
          ),
          SizedBox(height: 14),
          Row(
            children: [
              _LibraryMetric(label: '歌曲', value: '${_tracks.length}'),
              SizedBox(width: 10),
              _LibraryMetric(label: '歌手', value: '${_artistGroups().length}'),
              SizedBox(width: 10),
              _LibraryMetric(label: '喜欢', value: '${_favoriteTrackIds.length}'),
              SizedBox(width: 10),
              _LibraryMetric(label: '记录', value: '${_playHistoryIds.length}'),
              Spacer(),
              if (_viewMode == _DesktopMusicViewMode.radio) ...[
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primaryBtn,
                    side: BorderSide(color: AppColors.primaryBtn),
                  ),
                  onPressed: _dailyRadioGenerating ? null : _runDailyRadioNow,
                  icon: _dailyRadioGenerating
                      ? SizedBox(
                          width: 14,
                          height: 14,
                          child: _buildTinyLoading(AppColors.primaryBtn),
                        )
                      : Icon(Icons.wb_sunny_outlined, size: 17),
                  label: Text(_dailyRadioGenerating ? '生成中' : '今日电台'),
                ),
                SizedBox(width: 8),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBtn,
                    foregroundColor: Colors.white,
                    elevation: 0,
                  ),
                  onPressed: _radioGenerating ? null : _generateRadioEpisode,
                  icon: _radioGenerating
                      ? SizedBox(
                          width: 14,
                          height: 14,
                          child: _buildTinyLoading(Colors.white),
                        )
                      : Icon(Icons.auto_awesome, size: 17),
                  label: Text(_radioGenerating ? '生成中' : '生成电台'),
                ),
              ],
              if (_viewMode != _DesktopMusicViewMode.radio)
                SizedBox(width: 310, child: _buildSearchField()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLibraryContent() {
    if (_viewMode == _DesktopMusicViewMode.radio) {
      return _buildRadioPanel();
    }
    if (_loading) {
      return _buildLoadingState('音乐加载中...');
    }
    if (_error != null) return _buildError();
    if (_viewMode == _DesktopMusicViewMode.artists) {
      return _buildArtistsPanel();
    }
    return _buildTrackList(_visibleTracks());
  }

  Widget _buildLoadingState(String text) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          LoadingAnimationWidget.staggeredDotsWave(
            color: AppColors.primaryBtn,
            size: 30,
          ),
          SizedBox(height: 14),
          Text(
            text,
            style: TextStyle(
              color: AppColors.secondaryText,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTinyLoading(Color color) {
    return LoadingAnimationWidget.staggeredDotsWave(
      color: color,
      size: 18,
    );
  }

  Widget _buildTrackList(List<Map<String, dynamic>> tracks) {
    if (tracks.isEmpty) {
      return Center(
        child: Text(
          _emptyText(),
          style: TextStyle(color: AppColors.secondaryText),
        ),
      );
    }
    return ListView.builder(
      padding: EdgeInsets.fromLTRB(14, 12, 14, 14),
      itemCount: tracks.length,
      itemBuilder: (context, index) {
        final track = tracks[index];
        return Obx(() {
          final active = _globalPlayerStore.currentTrack?['id'] == track['id'];
          final favorite = _favoriteTrackIds.contains(track['id']?.toString());
          return _DesktopTrackItem(
            active: active,
            favorite: favorite,
            index: index,
            onFavoriteTap: () => _toggleFavorite(track),
            onTap: () => _playTrack(track, index),
            track: track,
          );
        });
      },
    );
  }

  Widget _buildArtistsPanel() {
    final groups = _artistGroups();
    if (groups.isEmpty) {
      return Center(
        child: Text('暂无歌手', style: TextStyle(color: AppColors.secondaryText)),
      );
    }
    if (_selectedArtistName != null) {
      final artistTracks = _artistTracks(_selectedArtistName!);
      return Column(
        children: [
          Container(
            height: 58,
            padding: EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.borderColor)),
            ),
            child: Row(
              children: [
                IconButton(
                  tooltip: '返回歌手列表',
                  onPressed: () => setState(() => _selectedArtistName = null),
                  icon: Icon(Icons.arrow_back,
                      color: AppColors.secondaryText, size: 20),
                ),
                SizedBox(width: 6),
                Expanded(
                  child: Text(
                    _selectedArtistName!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.primaryText,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Text(
                  '${artistTracks.length} 首歌曲',
                  style: TextStyle(
                    color: AppColors.secondaryText,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Expanded(child: _buildTrackList(artistTracks)),
        ],
      );
    }
    final entries = groups.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    return GridView.builder(
      padding: EdgeInsets.fromLTRB(14, 14, 14, 14),
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 260,
        mainAxisExtent: 104,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        final firstTrack = entry.value.first;
        return _ArtistCard(
          artist: entry.key,
          coverUrl: _albumField(firstTrack, 'picUrl'),
          count: entry.value.length,
          onTap: () => setState(() => _selectedArtistName = entry.key),
        );
      },
    );
  }

  Widget _buildNowPlayingMini() {
    return Obx(() {
      final track = _globalPlayerStore.currentTrack;
      if (track == null) {
        return Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.navigationBg.withValues(alpha: 0.62),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.borderColor),
          ),
          child: Text(
            '还没有播放歌曲',
            style: TextStyle(color: AppColors.secondaryText, fontSize: 12),
          ),
        );
      }
      return Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.navigationBg.withValues(alpha: 0.72),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '正在播放',
              style: TextStyle(
                color: AppColors.secondaryText,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 8),
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: NetImage(
                    _albumField(track, 'picUrl'),
                    width: 42,
                    height: 42,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(width: 9),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        track['name'] ?? '未知歌曲',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppColors.primaryText,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        _artistName(track),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppColors.secondaryText,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildRadioPanel() {
    return Column(
      children: [
        Container(
          margin: EdgeInsets.fromLTRB(14, 12, 14, 10),
          padding: EdgeInsets.fromLTRB(14, 13, 14, 13),
          decoration: BoxDecoration(
            color: AppColors.bgBtn.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.borderColor),
          ),
          child: Row(
            children: [
              _PlainIcon(
                icon: Icons.radio,
                active: true,
                size: 44,
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '节目流程',
                      style: TextStyle(
                        color: AppColors.primaryText,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '${_dailyRadioSummary()} 生成后会按“开场语音、推荐歌曲、收尾语音”顺序加入播放队列。',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.secondaryText,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 12),
              _PlainIcon(
                icon: Icons.playlist_play,
                active: true,
                size: 38,
              ),
            ],
          ),
        ),
        if (_radioError != null)
          Padding(
            padding: EdgeInsets.fromLTRB(12, 0, 12, 8),
            child: Text(
              _radioError!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.redAccent, fontSize: 12),
            ),
          ),
        if (_latestRadioUsesLegacyShape())
          Container(
            width: double.infinity,
            margin: EdgeInsets.fromLTRB(14, 0, 14, 10),
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.bgBtn.withValues(alpha: 0.52),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.primaryBtn.withValues(alpha: 0.28),
              ),
            ),
            child: Row(
              children: [
                _PlainIcon(
                  icon: Icons.sync_problem,
                  active: true,
                  size: 32,
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'NAS 当前还在返回旧电台结构，客户端已按“串词 + 歌曲队列”兼容播放；重新部署 NAS 服务端后才会有完整开场、歌曲、收尾语音。',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.secondaryText,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        Expanded(
          child: _radioLoading
              ? _buildLoadingState('电台加载中...')
              : _radioEpisodes.isEmpty
                  ? Center(
                      child: Text(
                        '还没有生成过电台',
                        style: TextStyle(color: AppColors.secondaryText),
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.fromLTRB(14, 0, 14, 14),
                      itemCount: _radioEpisodes.length,
                      itemBuilder: (context, index) {
                        final episode = _radioEpisodes[index];
                        return _RadioEpisodeItem(
                          episode: episode,
                          onTap: () => _playRadioEpisode(episode),
                        );
                      },
                    ),
        ),
      ],
    );
  }

  String _dailyRadioSummary() {
    final status = _dailyRadioStatus;
    if (status == null) {
      return '参考当前列表生成一期私人电台，正在读取 NAS 电台状态。';
    }
    final weather = status['weather'];
    final city =
        weather is Map ? weather['city']?.toString() ?? '陕西西安' : '陕西西安';
    final time = status['time']?.toString() ?? '07:30';
    final nextRun = status['nextRunAt']?.toString() ?? '';
    final nextText = nextRun.isEmpty ? '' : '，下次 $nextRun';
    final minimaxReady = _radioStatus?['minimaxConfigured'] == true;
    final voice = _radioStatus?['voiceId']?.toString() ?? '';
    final engine = minimaxReady ? 'MiniMax $voice' : '测试音频';
    return '每天 $time 根据$city天气和最近听歌自动生成，$engine$nextText。';
  }

  bool _latestRadioUsesLegacyShape() {
    if (_radioEpisodes.isEmpty) return false;
    final latest = _radioEpisodes.first;
    final segments = latest['segments'];
    final sourceTrackIds = latest['sourceTrackIds'];
    final hasSegments = segments is List && segments.isNotEmpty;
    final hasSourceTracks = sourceTrackIds is List && sourceTrackIds.isNotEmpty;
    return !hasSegments && hasSourceTracks;
  }

  String _contentTitle() {
    switch (_viewMode) {
      case _DesktopMusicViewMode.tracks:
        return '音乐列表';
      case _DesktopMusicViewMode.artists:
        return _selectedArtistName == null ? '歌手列表' : _selectedArtistName!;
      case _DesktopMusicViewMode.favorites:
        return '喜欢的音乐';
      case _DesktopMusicViewMode.history:
        return '播放记录';
      case _DesktopMusicViewMode.radio:
        return '今日电台';
    }
  }

  String _contentSubtitle() {
    switch (_viewMode) {
      case _DesktopMusicViewMode.tracks:
        return '从 NAS 曲库读取，支持搜索、播放和设为喜欢。';
      case _DesktopMusicViewMode.artists:
        return _selectedArtistName == null
            ? '按歌手整理你的曲库，点击歌手后进入歌曲列表。'
            : '当前歌手的全部歌曲，点击即可播放。';
      case _DesktopMusicViewMode.favorites:
        return '这里是你手动收藏的歌曲。';
      case _DesktopMusicViewMode.history:
        return '按最近播放顺序排列，最多保留 80 首。';
      case _DesktopMusicViewMode.radio:
        return '生成开场语音、推荐歌曲队列和收尾语音，然后按节目顺序播放。';
    }
  }

  String _emptyText() {
    switch (_viewMode) {
      case _DesktopMusicViewMode.favorites:
        return '还没有喜欢的歌曲';
      case _DesktopMusicViewMode.history:
        return '还没有播放记录';
      default:
        return '暂无歌曲';
    }
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off, color: AppColors.primaryBtn, size: 42),
            SizedBox(height: 12),
            Text(
              'NAS 音乐服务连接失败',
              style: TextStyle(color: AppColors.primaryText),
            ),
            SizedBox(height: 8),
            Text(
              _error ?? '',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.secondaryText, fontSize: 12),
            ),
            SizedBox(height: 14),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBtn,
                foregroundColor: Colors.white,
              ),
              onPressed: () => _loadTracks(_searchController.text),
              child: Text('重试'),
            ),
          ],
        ),
      ),
    );
  }

  String _artistName(Map<String, dynamic> track) {
    final artists = track['ar'];
    if (artists is List && artists.isNotEmpty && artists.first is Map) {
      return artists.first['name']?.toString() ?? '未知歌手';
    }
    return '未知歌手';
  }

  String _albumField(
    Map<String, dynamic> track,
    String key, {
    String fallback = '',
  }) {
    final album = track['al'];
    if (album is Map) return album[key]?.toString() ?? fallback;
    final rawAlbum = track['album'];
    if (rawAlbum is Map) {
      if (key == 'picUrl') {
        return NasMusicApi.resolveAssetUrl(
          rawAlbum['coverArtUrl']?.toString() ?? rawAlbum['picUrl']?.toString(),
        );
      }
      return rawAlbum[key]?.toString() ?? fallback;
    }
    if (key == 'picUrl') {
      return NasMusicApi.resolveAssetUrl(track['coverArtUrl']?.toString());
    }
    return fallback;
  }

  List<Map<String, dynamic>> _visibleTracks() {
    if (_viewMode == _DesktopMusicViewMode.favorites) {
      return _tracks
          .where((track) => _favoriteTrackIds.contains(track['id']?.toString()))
          .toList();
    }
    if (_viewMode == _DesktopMusicViewMode.history) {
      final byId = {
        for (final track in _tracks) track['id']?.toString() ?? '': track,
      };
      return _playHistoryIds
          .map((id) => byId[id])
          .whereType<Map<String, dynamic>>()
          .toList();
    }
    if (_viewMode == _DesktopMusicViewMode.artists &&
        _selectedArtistName != null) {
      return _artistTracks(_selectedArtistName!);
    }
    return _tracks;
  }

  Map<String, List<Map<String, dynamic>>> _artistGroups() {
    final groups = <String, List<Map<String, dynamic>>>{};
    for (final track in _tracks) {
      final artist = _artistName(track);
      groups.putIfAbsent(artist, () => []).add(track);
    }
    return groups;
  }

  List<Map<String, dynamic>> _artistTracks(String artist) {
    return _tracks.where((track) => _artistName(track) == artist).toList();
  }
}

enum _DesktopMusicViewMode { tracks, artists, favorites, history, radio }

class _StarFieldBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _StarFieldPainter(isDark: AppColors.isDark),
      child: SizedBox.expand(),
    );
  }
}

class _StarFieldPainter extends CustomPainter {
  _StarFieldPainter({required this.isDark});

  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final background = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: isDark
            ? [
                Color(0xFF05070A),
                Color(0xFF0A1016),
                Color(0xFF06080B),
              ]
            : [
                Color(0xFFF8FAFC),
                Color(0xFFF2F5F9),
                Color(0xFFFFFFFF),
              ],
      ).createShader(rect);
    canvas.drawRect(rect, background);

    final starPaint = Paint();
    final count = isDark ? 180 : 90;
    for (var i = 0; i < count; i++) {
      final x = ((i * 97) % math.max(size.width, 1)).toDouble();
      final y = ((i * 53) % math.max(size.height, 1)).toDouble();
      final pulse = ((i * 37) % 100) / 100;
      final radius = 0.45 + pulse * 0.85;
      final alpha = isDark ? 0.16 + pulse * 0.34 : 0.08 + pulse * 0.12;
      starPaint.color = (isDark ? Colors.white : AppColors.primaryBtn)
          .withValues(alpha: alpha);
      canvas.drawCircle(Offset(x, y), radius, starPaint);
    }

    if (isDark) {
      final glowPaint = Paint()
        ..shader = RadialGradient(
          colors: [
            AppColors.primaryBtn.withValues(alpha: 0.16),
            Colors.transparent,
          ],
        ).createShader(
          Rect.fromCircle(
            center: Offset(size.width * 0.55, size.height * 0.45),
            radius: size.width * 0.38,
          ),
        );
      canvas.drawRect(rect, glowPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _StarFieldPainter oldDelegate) {
    return oldDelegate.isDark != isDark;
  }
}

class _ReferenceNavItem extends StatelessWidget {
  _ReferenceNavItem({
    required this.active,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final bool active;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 18),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Row(
          children: [
            Icon(
              icon,
              color: active ? AppColors.primaryBtn : AppColors.primaryText,
              size: 24,
            ),
            SizedBox(width: 18),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: active ? AppColors.primaryBtn : AppColors.primaryText,
                  fontSize: 15,
                  fontWeight: active ? FontWeight.w800 : FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReferenceToolbarAction extends StatelessWidget {
  _ReferenceToolbarAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primaryText, size: 20),
            SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: AppColors.primaryText,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReferenceTab extends StatelessWidget {
  _ReferenceTab({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 86,
        height: 44,
        alignment: Alignment.centerLeft,
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: active ? AppColors.primaryBtn : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active ? AppColors.primaryBtn : AppColors.primaryText,
            fontSize: 17,
            fontWeight: active ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _ReferencePrimaryButton extends StatelessWidget {
  _ReferencePrimaryButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryBtn,
        disabledBackgroundColor: AppColors.primaryBtn.withValues(alpha: 0.38),
        foregroundColor: Colors.white,
        elevation: 0,
        minimumSize: Size(0, 40),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: EdgeInsets.symmetric(horizontal: 17),
      ),
      onPressed: onTap,
      icon: Icon(icon, size: 18),
      label: Text(
        label,
        style: TextStyle(fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _ReferenceGhostButton extends StatelessWidget {
  _ReferenceGhostButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        foregroundColor:
            onTap == null ? AppColors.secondaryText : AppColors.primaryText,
        disabledForegroundColor: AppColors.secondaryText,
        side: BorderSide(color: AppColors.borderColor),
        minimumSize: Size(0, 40),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: EdgeInsets.symmetric(horizontal: 14),
      ),
      onPressed: onTap,
      icon: Icon(icon, size: 18),
      label: Text(
        label,
        style: TextStyle(fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _ReferenceIconButton extends StatelessWidget {
  _ReferenceIconButton({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.borderColor),
        ),
        child: Icon(icon, color: AppColors.primaryText, size: 22),
      ),
    );
  }
}

class _ReferencePanel extends StatelessWidget {
  _ReferencePanel({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.navigationBg
            .withValues(alpha: AppColors.isDark ? 0.54 : 0.86),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.borderColor),
        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withValues(alpha: AppColors.isDark ? 0.22 : 0.05),
            blurRadius: 18,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _RightRailTrack extends StatelessWidget {
  _RightRailTrack({
    required this.track,
    required this.artistName,
    required this.coverUrl,
    required this.duration,
    required this.onTap,
  });

  final Map<String, dynamic> track;
  final String artistName;
  final String coverUrl;
  final String duration;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.only(bottom: 13),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: NetImage(
                coverUrl,
                width: 44,
                height: 44,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    track['name']?.toString() ?? '未知歌曲',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.primaryText,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    artistName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.secondaryText,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 8),
            Text(
              duration,
              style: TextStyle(
                color: AppColors.secondaryText,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlainIcon extends StatelessWidget {
  _PlainIcon({
    required this.icon,
    this.active = false,
    this.size = 20,
  });

  final IconData icon;
  final bool active;
  final double size;

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.primaryBtn : AppColors.secondaryText;
    return Icon(
      icon,
      size: size,
      color: color,
    );
  }
}

class _LibraryNavItem extends StatelessWidget {
  _LibraryNavItem({
    required this.active,
    required this.icon,
    required this.label,
    required this.count,
    required this.onTap,
  });

  final bool active;
  final IconData icon;
  final String label;
  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Container(
          height: 42,
          padding: EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              _PlainIcon(
                icon: icon,
                active: active,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color:
                        active ? AppColors.primaryBtn : AppColors.primaryText,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                '$count',
                style: TextStyle(
                  color:
                      active ? AppColors.primaryBtn : AppColors.secondaryText,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LibraryMetric extends StatelessWidget {
  _LibraryMetric({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 32,
      padding: EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.bgBtn.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Row(
        children: [
          Text(
            value,
            style: TextStyle(
              color: AppColors.primaryText,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: AppColors.secondaryText,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _ArtistCard extends StatelessWidget {
  _ArtistCard({
    required this.artist,
    required this.coverUrl,
    required this.count,
    required this.onTap,
  });

  final String artist;
  final String coverUrl;
  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.navigationBg.withValues(alpha: 0.52),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.borderColor),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: NetImage(
                coverUrl,
                width: 58,
                height: 58,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    artist,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.primaryText,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    '$count 首歌曲',
                    style: TextStyle(
                      color: AppColors.secondaryText,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: AppColors.secondaryText,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class _DesktopTrackItem extends StatelessWidget {
  _DesktopTrackItem({
    required this.active,
    required this.favorite,
    required this.index,
    required this.onFavoriteTap,
    required this.onTap,
    required this.track,
  });

  final bool active;
  final bool favorite;
  final int index;
  final VoidCallback onFavoriteTap;
  final VoidCallback onTap;
  final Map<String, dynamic> track;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        highlightColor: AppColors.primaryBtn.withValues(alpha: 0.18),
        splashColor: AppColors.primaryBtn.withValues(alpha: 0.26),
        onTap: onTap,
        child: Container(
          height: 74,
          padding: EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: active
                ? AppColors.bgBtn
                : AppColors.navigationBg.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: active ? AppColors.primaryBtn : AppColors.borderColor,
            ),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 28,
                child: Text(
                  '${index + 1}',
                  style: TextStyle(
                    color:
                        active ? AppColors.primaryBtn : AppColors.secondaryText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: NetImage(
                  _albumField(track, 'picUrl'),
                  width: 48,
                  height: 48,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      track['name'] ?? '未知歌曲',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.primaryText,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      _artistName(track),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.secondaryText,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: favorite ? '取消喜欢' : '设为喜欢',
                onPressed: onFavoriteTap,
                icon: Icon(
                  favorite ? Icons.favorite : Icons.favorite_border,
                  color:
                      favorite ? AppColors.primaryBtn : AppColors.secondaryText,
                  size: 18,
                ),
              ),
              Icon(
                active ? Icons.volume_up : Icons.play_arrow,
                color: active ? AppColors.primaryBtn : AppColors.secondaryText,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _artistName(Map<String, dynamic> track) {
    final artists = track['ar'];
    if (artists is List && artists.isNotEmpty && artists.first is Map) {
      return artists.first['name']?.toString() ?? '未知歌手';
    }
    return '未知歌手';
  }

  String _albumField(Map<String, dynamic> track, String key) {
    final album = track['al'];
    if (album is Map) return album[key]?.toString() ?? '';
    final rawAlbum = track['album'];
    if (rawAlbum is Map && key == 'picUrl') {
      return NasMusicApi.resolveAssetUrl(
        rawAlbum['coverArtUrl']?.toString() ?? rawAlbum['picUrl']?.toString(),
      );
    }
    if (key == 'picUrl') {
      return NasMusicApi.resolveAssetUrl(track['coverArtUrl']?.toString());
    }
    return '';
  }
}

class _RadioEpisodeItem extends StatelessWidget {
  _RadioEpisodeItem({
    required this.episode,
    required this.onTap,
  });

  final Map<String, dynamic> episode;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final title = episode['title']?.toString() ?? '未命名电台';
    final summary = episode['summary']?.toString() ?? '';
    final generator = episode['generator']?.toString() ?? 'mock';
    final duration = _formatDuration(episode['durationSeconds']);
    final segments = episode['segments'];
    final trackCount = segments is List
        ? segments.where((item) {
            return item is Map && item['type']?.toString() == 'track';
          }).length
        : 0;
    final sourceTrackIds = episode['sourceTrackIds'];
    final fallbackTrackCount =
        sourceTrackIds is List ? sourceTrackIds.length : 0;
    final displayTrackCount = trackCount > 0 ? trackCount : fallbackTrackCount;
    final segmentText = displayTrackCount > 0 ? ' · $displayTrackCount 首歌' : '';
    final generatorText = generator == 'minimax'
        ? (trackCount > 0 ? 'MiniMax 开场/收尾' : 'MiniMax 串词')
        : '测试音频';
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Container(
          constraints: BoxConstraints(minHeight: 84),
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.navigationBg.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.borderColor),
          ),
          child: Row(
            children: [
              _PlainIcon(
                icon: Icons.radio,
                active: true,
                size: 48,
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.primaryText,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      summary.isEmpty ? 'NAS 生成的私人音乐电台' : summary,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.secondaryText,
                        fontSize: 12,
                        height: 1.3,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      '$generatorText$segmentText · $duration',
                      style: TextStyle(
                        color: AppColors.secondaryText,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 12),
              Icon(
                Icons.play_arrow,
                color: AppColors.primaryBtn,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDuration(dynamic seconds) {
    final value =
        seconds is int ? seconds : int.tryParse(seconds?.toString() ?? '') ?? 0;
    if (value <= 0) return '--:--';
    final minutes = (value ~/ 60).toString().padLeft(2, '0');
    final rest = (value % 60).toString().padLeft(2, '0');
    return '$minutes:$rest';
  }
}

class _RadioStatusBadge extends StatelessWidget {
  _RadioStatusBadge({required this.status});

  final Map<String, dynamic>? status;

  @override
  Widget build(BuildContext context) {
    final ready = status?['minimaxConfigured'] == true;
    final label = ready ? 'MiniMax 已就绪' : '测试音频';
    final color = ready ? AppColors.primaryBtn : AppColors.secondaryText;
    return Container(
      height: 32,
      padding: EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            ready ? Icons.check_circle : Icons.info_outline,
            color: color,
            size: 15,
          ),
          SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
