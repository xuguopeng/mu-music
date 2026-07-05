import 'charge_info_list.songs.model.dart';
import 'free_trial_privilege.songs.model.dart';

class Privilege {
  int? id;
  int? fee;
  int? payed;
  int? realPayed;
  int? st;
  int? pl;
  int? dl;
  int? sp;
  int? cp;
  int? subp;
  bool? cs;
  int? maxbr;
  int? fl;
  dynamic pc;
  bool? toast;
  int? flag;
  bool? paidBigBang;
  bool? preSell;
  int? playMaxbr;
  int? downloadMaxbr;
  String? maxBrLevel;
  String? playMaxBrLevel;
  String? downloadMaxBrLevel;
  String? plLevel;
  String? dlLevel;
  String? flLevel;
  dynamic rscl;
  FreeTrialPrivilege? freeTrialPrivilege;
  int? rightSource;
  List<ChargeInfoList>? chargeInfoList;
  int? code;
  dynamic message;
  dynamic plLevels;
  dynamic dlLevels;
  dynamic ignoreCache;
  dynamic bd;

  Privilege({
    this.id,
    this.fee,
    this.payed,
    this.realPayed,
    this.st,
    this.pl,
    this.dl,
    this.sp,
    this.cp,
    this.subp,
    this.cs,
    this.maxbr,
    this.fl,
    this.pc,
    this.toast,
    this.flag,
    this.paidBigBang,
    this.preSell,
    this.playMaxbr,
    this.downloadMaxbr,
    this.maxBrLevel,
    this.playMaxBrLevel,
    this.downloadMaxBrLevel,
    this.plLevel,
    this.dlLevel,
    this.flLevel,
    this.rscl,
    this.freeTrialPrivilege,
    this.rightSource,
    this.chargeInfoList,
    this.code,
    this.message,
    this.plLevels,
    this.dlLevels,
    this.ignoreCache,
    this.bd,
  });

  factory Privilege.fromJson(Map<String, dynamic> json) => Privilege(
        id: json['id'] as int?,
        fee: json['fee'] as int?,
        payed: json['payed'] as int?,
        realPayed: json['realPayed'] as int?,
        st: json['st'] as int?,
        pl: json['pl'] as int?,
        dl: json['dl'] as int?,
        sp: json['sp'] as int?,
        cp: json['cp'] as int?,
        subp: json['subp'] as int?,
        cs: json['cs'] as bool?,
        maxbr: json['maxbr'] as int?,
        fl: json['fl'] as int?,
        pc: json['pc'] as dynamic,
        toast: json['toast'] as bool?,
        flag: json['flag'] as int?,
        paidBigBang: json['paidBigBang'] as bool?,
        preSell: json['preSell'] as bool?,
        playMaxbr: json['playMaxbr'] as int?,
        downloadMaxbr: json['downloadMaxbr'] as int?,
        maxBrLevel: json['maxBrLevel'] as String?,
        playMaxBrLevel: json['playMaxBrLevel'] as String?,
        downloadMaxBrLevel: json['downloadMaxBrLevel'] as String?,
        plLevel: json['plLevel'] as String?,
        dlLevel: json['dlLevel'] as String?,
        flLevel: json['flLevel'] as String?,
        rscl: json['rscl'] as dynamic,
        freeTrialPrivilege: json['freeTrialPrivilege'] == null
            ? null
            : FreeTrialPrivilege.fromJson(
                json['freeTrialPrivilege'] as Map<String, dynamic>),
        rightSource: json['rightSource'] as int?,
        chargeInfoList: (json['chargeInfoList'] as List<dynamic>?)
            ?.map((e) => ChargeInfoList.fromJson(e as Map<String, dynamic>))
            .toList(),
        code: json['code'] as int?,
        message: json['message'] as dynamic,
        plLevels: json['plLevels'] as dynamic,
        dlLevels: json['dlLevels'] as dynamic,
        ignoreCache: json['ignoreCache'] as dynamic,
        bd: json['bd'] as dynamic,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'fee': fee,
        'payed': payed,
        'realPayed': realPayed,
        'st': st,
        'pl': pl,
        'dl': dl,
        'sp': sp,
        'cp': cp,
        'subp': subp,
        'cs': cs,
        'maxbr': maxbr,
        'fl': fl,
        'pc': pc,
        'toast': toast,
        'flag': flag,
        'paidBigBang': paidBigBang,
        'preSell': preSell,
        'playMaxbr': playMaxbr,
        'downloadMaxbr': downloadMaxbr,
        'maxBrLevel': maxBrLevel,
        'playMaxBrLevel': playMaxBrLevel,
        'downloadMaxBrLevel': downloadMaxBrLevel,
        'plLevel': plLevel,
        'dlLevel': dlLevel,
        'flLevel': flLevel,
        'rscl': rscl,
        'freeTrialPrivilege': freeTrialPrivilege?.toJson(),
        'rightSource': rightSource,
        'chargeInfoList': chargeInfoList?.map((e) => e.toJson()).toList(),
        'code': code,
        'message': message,
        'plLevels': plLevels,
        'dlLevels': dlLevels,
        'ignoreCache': ignoreCache,
        'bd': bd,
      };
}
