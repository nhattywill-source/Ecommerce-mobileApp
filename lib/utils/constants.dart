class ApiConstants {
  static const String baseUrl = 'https://fakestoreapi.com';
  static const String products = '$baseUrl/products';
  static const String categories = '$baseUrl/products/categories';
  static String productsByCategory(String category) =>
      '$baseUrl/products/category/$category';
  static const String login = '$baseUrl/auth/login';
  static const String users = '$baseUrl/users';
  static const String carts = '$baseUrl/carts';
}

class StorageKeys {
  static const String authToken = 'auth_token';
  static const String currentUser = 'current_user';
  static const String cartItems = 'cart_items';
  static const String favoriteIds = 'favorite_ids';
  static const String onboardingSeen = 'onboarding_seen';
}

class AppStrings {
  static const String appName = 'ShopEase';
}
