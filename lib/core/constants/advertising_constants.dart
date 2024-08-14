class AdvertisingConstants {
  static const int minCpmValue = 125;

  static const Map<int, String> advTypes = {
    4: "в каталоге",
    5: "в карточке",
    6: "в поиске",
    7: "на главной странице",
    8: "автокампания",
    9: "поиск + каталог",
  };
  static const Map<int, String> advStatus = {
    -1: "удаление",
    4: "готова к запуску",
    7: "завершена",
    8: "отказался",
    9: "идут показы",
    11: "приостановленно",
  };
}

class AdvertStatusConstants {
  static const int deleted = -1;
  static const int readyToStart = 4;
  static const int finished = 7;
  static const int refused = 8;
  static const int active = 9;
  static const int paused = 11;
  static const List<int> useable = [active, paused];
}

class AdvertTypeConstants {
  // static const int inCatalog = 4;
  // static const int inCard = 5;
  // static const int inSearch = 6;
  // static const int inRecomendation = 7;
  static const int auto = 8;
  static const int searchPlusCatalog = 9;
}
