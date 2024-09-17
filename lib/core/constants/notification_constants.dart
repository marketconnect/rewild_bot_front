class NotificationConditionConstants {
  static const String nameChanged = "name";
  static const String picsChanged = "pic_count";
  static const String reviewRatingChanged = "review_rating";
  static const String stocksLessThan = "stock_level";

  static const String totalStocksLessThan = "total_stock_level";

  static const String promoChanged = "promo";
  static const String priceChanged = "price";

  static const String budgetLessThan = "1";
  static const String review = '12';
  static const String question = "14";

  // Метод для проверки, является ли уведомление карточкой
  static bool isCardNotification(String condition) {
    switch (condition) {
      case nameChanged:
      case picsChanged:
      case priceChanged:
      case promoChanged:
      case reviewRatingChanged:
      case stocksLessThan:
        return true;
      default:
        return false;
    }
  }

  static bool isAdvertNotification(String condition) {
    return condition ==
        budgetLessThan; // Добавьте другие условия при необходимости
  }

  // Метод для проверки, является ли уведомление о количестве отзывов
  static bool isFeedbackQtyNotification(String condition) {
    return condition == review || condition == question;
  }
}
