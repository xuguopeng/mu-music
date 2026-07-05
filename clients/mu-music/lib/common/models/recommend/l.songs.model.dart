class L {
  int? br;
  int? fid;
  int? size;
  int? vd;
  int? sr;

  L({this.br, this.fid, this.size, this.vd, this.sr});

  factory L.fromJson(Map<String, dynamic> json) => L(
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
