import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/cart_item.dart';
import '../models/user.dart';
import '../utils/constants.dart';

/// Wraps SharedPreferences to persist auth session, cart, and favorites
/// across app restarts.
class StorageService {
  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(StorageKeys.authToken, token);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(StorageKeys.authToken);
  }

  Future<void> saveUser(AppUser user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(StorageKeys.currentUser, json.encode(user.toJson()));
  }

  Future<AppUser?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(StorageKeys.currentUser);
    if (raw == null) return null;
    return AppUser.fromJson(json.decode(raw));
  }

  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(StorageKeys.authToken);
    await prefs.remove(StorageKeys.currentUser);
  }

  Future<void> saveCart(List<CartItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = json.encode(items.map((e) => e.toJson()).toList());
    await prefs.setString(StorageKeys.cartItems, encoded);
  }

  Future<List<CartItem>> getCart() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(StorageKeys.cartItems);
    if (raw == null) return [];
    final List<dynamic> data = json.decode(raw);
    return data.map((e) => CartItem.fromJson(e)).toList();
  }

  Future<void> saveFavoriteIds(Set<int> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      StorageKeys.favoriteIds,
      ids.map((e) => e.toString()).toList(),
    );
  }

  Future<Set<int>> getFavoriteIds() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(StorageKeys.favoriteIds);
    if (raw == null) return {};
    return raw.map((e) => int.parse(e)).toSet();
  }
}
