class CampaignData {
  final int views;
  final int clicks;
  final double ctr;
  final double cpc;
  final double sum;
  final int atbs;
  final int orders;
  final int cr;
  final int shks;
  final double sumPrice;
  final List<String> dates;
  final List<CampaignDataDay> days;
  final List<CampaignDataBoosterStat> boosterStats;
  final int advertId;

  CampaignData({
    required this.views,
    required this.clicks,
    required this.ctr,
    required this.cpc,
    required this.sum,
    required this.atbs,
    required this.orders,
    required this.cr,
    required this.shks,
    required this.sumPrice,
    required this.dates,
    required this.days,
    required this.boosterStats,
    required this.advertId,
  });

  factory CampaignData.fromJson(Map<String, dynamic> json) {
    final dates =
        json['dates'] != null ? List<String>.from(json['dates']) : <String>[];

    final days = json['days'] != null
        ? List<CampaignDataDay>.from(
            json['days'].map((x) => CampaignDataDay.fromJson(x)))
        : <CampaignDataDay>[];
    final boosterStats = json['boosterStats'] != null
        ? List<CampaignDataBoosterStat>.from(json['boosterStats']
            .map((x) => CampaignDataBoosterStat.fromJson(x)))
        : <CampaignDataBoosterStat>[];

    return CampaignData(
      views: (json['views'] as num).toInt(),
      clicks: (json['clicks'] as num).toInt(),
      ctr: json['ctr'].toDouble(),
      cpc: json['cpc'].toDouble(),
      sum: json['sum'].toDouble(),
      atbs: (json['atbs'] as num).toInt(),
      orders: (json['orders'] as num).toInt(),
      cr: (json['cr'] as num).toInt(),
      shks: (json['shks'] as num).toInt(),
      sumPrice: json['sum_price'].toDouble(),
      dates: dates,
      days: days,
      boosterStats: boosterStats,
      advertId: json['advertId'],
    );
  }
}

class CampaignDataDay {
  final String date;
  final int views;
  final int clicks;
  final double ctr;
  final double cpc;
  final double sum;
  final int atbs;
  final int orders;
  final int cr;
  final int shks;
  final double sumPrice;
  final List<CampaignDataApp> apps;

  CampaignDataDay({
    required this.date,
    required this.views,
    required this.clicks,
    required this.ctr,
    required this.cpc,
    required this.sum,
    required this.atbs,
    required this.orders,
    required this.cr,
    required this.shks,
    required this.sumPrice,
    required this.apps,
  });

  double get cpm => (sum / views) * 1000;

  double get roi => ((sumPrice - sum) / sum) * 100;

  factory CampaignDataDay.fromJson(Map<String, dynamic> json) {
    return CampaignDataDay(
      date: json['date'],
      views: (json['views'] as num).toInt(),
      clicks: (json['clicks'] as num).toInt(),
      ctr: json['ctr'].toDouble(),
      cpc: json['cpc'].toDouble(),
      sum: json['sum'].toDouble(),
      atbs: (json['atbs'] as num).toInt(),
      orders: (json['orders'] as num).toInt(),
      cr: (json['cr'] as num).toInt(),
      shks: (json['shks'] as num).toInt(),
      sumPrice: json['sum_price'].toDouble(),
      apps: List<CampaignDataApp>.from(
          json['apps'].map((x) => CampaignDataApp.fromJson(x))),
    );
  }
}

class CampaignDataApp {
  final int views;
  final int clicks;
  final double ctr;
  final double cpc;
  final double sum;
  final int atbs;
  final int orders;
  final int cr;
  final int shks;
  final double sumPrice;
  final List<CampaignDataNm> nm;
  final int appType;

  CampaignDataApp({
    required this.views,
    required this.clicks,
    required this.ctr,
    required this.cpc,
    required this.sum,
    required this.atbs,
    required this.orders,
    required this.cr,
    required this.shks,
    required this.sumPrice,
    required this.nm,
    required this.appType,
  });

  factory CampaignDataApp.fromJson(Map<String, dynamic> json) {
    return CampaignDataApp(
      views: (json['views'] as num).toInt(),
      clicks: (json['clicks'] as num).toInt(),
      ctr: json['ctr'].toDouble(),
      cpc: json['cpc'].toDouble(),
      sum: json['sum'].toDouble(),
      atbs: (json['atbs'] as num).toInt(),
      orders: (json['orders'] as num).toInt(),
      cr: (json['cr'] as num).toInt(),
      shks: (json['shks'] as num).toInt(),
      sumPrice: json['sum_price'].toDouble(),
      nm: List<CampaignDataNm>.from(
          json['nm'].map((x) => CampaignDataNm.fromJson(x))),
      appType: json['appType'],
    );
  }
}

class CampaignDataNm {
  final int views;
  final int clicks;
  final double ctr;
  final double cpc;
  final double sum;
  final int atbs;
  final int orders;
  final int cr;
  final int shks;
  final double sumPrice;
  final String name;
  final int nmId;

  CampaignDataNm({
    required this.views,
    required this.clicks,
    required this.ctr,
    required this.cpc,
    required this.sum,
    required this.atbs,
    required this.orders,
    required this.cr,
    required this.shks,
    required this.sumPrice,
    required this.name,
    required this.nmId,
  });

  factory CampaignDataNm.fromJson(Map<String, dynamic> json) {
    return CampaignDataNm(
      views: (json['views'] as num).toInt(),
      clicks: (json['clicks'] as num).toInt(),
      ctr: json['ctr'].toDouble(),
      cpc: json['cpc'].toDouble(),
      sum: json['sum'].toDouble(),
      atbs: (json['atbs'] as num).toInt(),
      orders: (json['orders'] as num).toInt(),
      cr: (json['cr'] as num).toInt(),
      shks: (json['shks'] as num).toInt(),
      sumPrice: json['sum_price'].toDouble(),
      name: json['name'],
      nmId: json['nmId'],
    );
  }
}

class CampaignDataBoosterStat {
  final String date;
  final int nm;
  final int avgPosition;

  CampaignDataBoosterStat({
    required this.date,
    required this.nm,
    required this.avgPosition,
  });

  factory CampaignDataBoosterStat.fromJson(Map<String, dynamic> json) {
    return CampaignDataBoosterStat(
      date: json['date'],
      nm: json['nm'],
      avgPosition: (json['avg_position'] as num).toInt(),
    );
  }
}
