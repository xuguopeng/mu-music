class Hr {
  int? br;
  int? fid;
  int? size;
  int? vd;
  int? sr;

  Hr({this.br, this.fid, this.size, this.vd, this.sr});

  factory Hr.fromJson(Map<String, dynamic> json) => Hr(
        br: json['br'] as int?,
        fid: json['fid'] as int?,
        size: json['size'] as int?,
        vd: json['vd'] as int?,
        sr: json['sr'] as int?,
      );

  Map<String, dynamic> toJson() => {
        'br': br,
        'fid': fid,
        'size': size,
        'vd': vd,
        'sr': sr,
      };
}
