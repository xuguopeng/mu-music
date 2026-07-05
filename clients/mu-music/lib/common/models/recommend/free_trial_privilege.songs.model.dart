class FreeTrialPrivilege {
  bool? resConsumable;
  bool? userConsumable;
  int? listenType;
  int? cannotListenReason;
  dynamic playReason;
  dynamic freeLimitTagType;

  FreeTrialPrivilege({
    this.resConsumable,
    this.userConsumable,
    this.listenType,
    this.cannotListenReason,
    this.playReason,
    this.freeLimitTagType,
  });

  factory FreeTrialPrivilege.fromJson(Map<String, dynamic> json) {
    return FreeTrialPrivilege(
      resConsumable: json['resConsumable'] as bool?,
      userConsumable: json['userConsumable'] as bool?,
      listenType: json['listenType'] as int?,
      cannotListenReason: json['cannotListenReason'] as int?,
      playReason: json['playReason'] as dynamic,
      freeLimitTagType: json['freeLimitTagType'] as dynamic,
    );
  }

  Map<String, dynamic> toJson() => {
        'resConsumable': resConsumable,
        'userConsumable': userConsumable,
        'listenType': listenType,
        'cannotListenReason': cannotListenReason,
        'playReason': playReason,
        'freeLimitTagType': freeLimitTagType,
      };
}
