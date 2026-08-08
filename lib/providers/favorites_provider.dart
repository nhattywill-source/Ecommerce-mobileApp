import 'package:flutter/foundation.dart';
import '../services/storage_service.dart';

class FavoritesProvider extends ChangeNotifier {
  final StorageService _storageService;

  FavoritesProvider({StorageService? storageService})
      : _storageService = storageService ?? StorageService();

  final Set<int> _favoriteIds = {};

  Set<int> get favoriteIds => Set.unmodifiable(_favoriteIds);
  int get count => _favoriteIds.length;

  Future<void> loadFavorites() async {
    final saved = await _storageService.getFavoriteIds();
    _favoriteIds
      ..clear()
      ..addAll(saved);
    notifyListeners();
  }

  bool isFavorite(int productId) => _favoriteIds.contains(productId);

  void toggleFavorite(int productId) {
    if (_favoriteIds.contains(productId)) {
      _favoriteIds.remove(productId);
    } else {
      _favoriteIds.add(productId);
    }
    _storageService.saveFavoriteIds(_favoriteIds);
    notifyListeners();
  }
}
