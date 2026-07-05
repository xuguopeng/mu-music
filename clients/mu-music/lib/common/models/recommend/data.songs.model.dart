import 'daily_song.songs.model.dart';
import 'recommend_reason.songs.model.dart';

class Data {
  bool? fromCache;
  List<DailySong>? dailySongs;
  List<dynamic>? orderSongs;
  List<RecommendReason>? recommendReasons;
  dynamic mvResourceInfos;
  bool? demote;
  bool? algReturnDemote;
  dynamic dailyRecommendInfo;

  Data({
    this.fromCache,
    this.dailySongs,
    this.orderSongs,
    this.recommendReasons,
    this.mvResourceInfos,
    this.demote,
    this.algReturnDemote,
    this.dailyRecommendInfo,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        fromCache: json['fromCache'] as bool?,
        dailySongs: (json['dailySongs'] as List<dynamic>?)
            ?.map((e) => DailySong.fromJson(e as Map<String, dynamic>))
            .toList(),
        orderSongs: json['orderSongs'] as List<dynamic>?,
        recommendReasons: (json['recommendReasons'] as List<dynamic>?)
            ?.map((e) => RecommendReason.fromJson(e as Map<String, dynamic>))
            .toList(),
        mvResourceInfos: json['mvResourceInfos'] as dynamic,
        demote: json['demote'] as bool?,
        algReturnDemote: json['algReturnDemote'] as bool?,
        dailyRecommendInfo: json['dailyRecommendInfo'] as dynamic,
      );

  Map<String, dynamic> toJson() => {
        'fromCache': fromCache,
        'dailySongs': dailySongs?.map((e) => e.toJson()).toList(),
        'orderSongs': orderSongs,
        'recommendReasons': recommendReasons?.map((e) => e.toJson()).toList(),
        'mvResourceInfos': mvResourceInfos,
        'demote': demote,
        'algReturnDemote': algReturnDemote,
        'dailyRecommendInfo': dailyRecommendInfo,
      };
}
