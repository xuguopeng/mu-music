class ChargeInfoList {
  int? rate;
  dynamic chargeUrl;
  dynamic chargeMessage;
  int? chargeType;

  ChargeInfoList({
    this.rate,
    this.chargeUrl,
    this.chargeMessage,
    this.chargeType,
  });

  factory ChargeInfoList.fromJson(Map<String, dynamic> json) {
    return ChargeInfoList(
      rate: json['rate'] as int?,
      chargeUrl: json['chargeUrl'] as dynamic,
      chargeMessage: json['chargeMessage'] as dynamic,
      chargeType: json['chargeType'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
        'rate': rate,
        'chargeUrl': chargeUrl,
        'chargeMessage': chargeMessage,
        'chargeType': chargeType,
      };
}
