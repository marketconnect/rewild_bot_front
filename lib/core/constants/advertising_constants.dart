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
