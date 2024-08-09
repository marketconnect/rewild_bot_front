class NotificationConditionConstants {
  static const int budgetLessThan = 1;
  static const int priceChanged = 2;
  static const int promoChanged = 3;
  static const int nameChanged = 4;
  static const int picsChanged = 5;
  static const int reviewRatingChanged = 6;
  static const int stocksLessThan = 7;
  static const int stocksInWhLessThan = 100;
  static const int sizeStocksLessThan = 9;
  static const int sizeStocksInWhLessThan = 10;
  static const int stocksMoreThan = 11;
  static const int review = 12;
  static const int question = 14;
  static const int ctrLessThan = 15;

  static bool isAdvertNotification(int condition) {
    switch (condition) {
      case NotificationConditionConstants.budgetLessThan ||
            NotificationConditionConstants.ctrLessThan:
        return true;
      default:
        return false;
    }
  }

  static bool isFeedbackQtyNotification(int condition) {
    switch (condition) {
      case NotificationConditionConstants.question:
        return true;
      case NotificationConditionConstants.review:
        return true;
      default:
        return false;
    }
  }

  static bool isCardNotification(int condition) {
    if (condition > 100) {
      return true;
    }
    switch (condition) {
      case NotificationConditionConstants.nameChanged:
        return true;
      case NotificationConditionConstants.picsChanged:
        return true;
      case NotificationConditionConstants.priceChanged:
        return true;

      case NotificationConditionConstants.promoChanged:
        return true;

      case NotificationConditionConstants.reviewRatingChanged:
        return true;

      case NotificationConditionConstants.sizeStocksInWhLessThan:
        return true;

      case NotificationConditionConstants.sizeStocksLessThan:
        return true;

      case NotificationConditionConstants.stocksLessThan:
        return true;
      default:
        return false;
    }
  }
}
