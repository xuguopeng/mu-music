class RecommendReason {
  int? songId;
  String? reason;
  String? reasonId;
  dynamic targetUrl;

  RecommendReason({
    this.songId,
    this.reason,
    this.reasonId,
    this.targetUrl,
  });

  factory RecommendReason.fromJson(Map<String, dynamic> json) {
    return RecommendReason(
      songId: json['songId'] as int?,
      reason: json['reason'] as String?,
      reasonId: json['reasonId'] as String?,
      targetUrl: json['targetUrl'] as dynamic,
    );
  }

  Map<String, dynamic> toJson() => {
        'songId': songId,
        'reason': reason,
        'reasonId': reasonId,
        'targetUrl': targetUrl,
      };
}
