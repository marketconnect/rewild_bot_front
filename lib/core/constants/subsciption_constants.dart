int getSubscriptionLimit({required String subscriptionTypeName}) {
  switch (subscriptionTypeName) {
    case "Free":
      return 5;
    case "Basic":
      return 25;
    case "Standard":
      return 50;
    case "Premium":
      return 100;
    default:
      return 0; // error
  }
}

double getSubscriptionBalance({required String subscriptionTypeName}) {
  switch (subscriptionTypeName) {
    case "Free":
      return 3;
    case "Basic":
      return 50;
    case "Standard":
      return 100;
    case "Premium":
      return 150;
    default:
      return 0; // error
  }
}

String getSubscriptionTypeByIndex({required int index}) {
  switch (index) {
    case 0:
      return "Basic";
    case 1:
      return "Standard";
    case 2:
      return "Premium";
    default:
      return "Free";
  }
}
