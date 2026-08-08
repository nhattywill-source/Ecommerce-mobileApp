import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/api_service.dart';

enum LoadStatus { initial, loading, loaded, error }

enum SortOption { none, priceLowToHigh, priceHighToLow, ratingHighToLow }

class ProductProvider extends ChangeNotifier {
  final ApiService _apiService;

  ProductProvider({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  List<Product> _allProducts = [];
  List<String> _categories = [];
  LoadStatus _status = LoadStatus.initial;
  String? _errorMessage;

  String _selectedCategory = 'All';
  String _searchQuery = '';
  SortOption _sortOption = SortOption.none;
  RangeValues _priceRange = const RangeValues(0, 1000);
  double _maxPrice = 1000;

  LoadStatus get status => _status;
  String? get errorMessage => _errorMessage;
  List<String> get categories => ['All', ..._categories];
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  SortOption get sortOption => _sortOption;
  RangeValues get priceRange => _priceRange;
  double get maxPrice => _maxPrice;

  List<Product> get filteredProducts {
    var list = List<Product>.from(_allProducts);

    if (_selectedCategory != 'All') {
      list = list.where((p) => p.category == _selectedCategory).toList();
    }

    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list.where((p) => p.title.toLowerCase().contains(q)).toList();
    }

    list = list
        .where((p) =>
            p.price >= _priceRange.start && p.price <= _priceRange.end)
        .toList();

    switch (_sortOption) {
      case SortOption.priceLowToHigh:
        list.sort((a, b) => a.price.compareTo(b.price));
        break;
      case SortOption.priceHighToLow:
        list.sort((a, b) => b.price.compareTo(a.price));
        break;
      case SortOption.ratingHighToLow:
        list.sort((a, b) => b.rating.rate.compareTo(a.rating.rate));
        break;
      case SortOption.none:
        break;
    }

    return list;
  }

  List<Product> get featuredProducts {
    final sorted = List<Product>.from(_allProducts)
      ..sort((a, b) => b.rating.rate.compareTo(a.rating.rate));
    return sorted.take(6).toList();
  }

  Future<void> loadProducts() async {
    _status = LoadStatus.loading;
    _errorMessage = null;
    notifyListeners();
    try {
      final results = await Future.wait([
        _apiService.fetchProducts(),
        _apiService.fetchCategories(),
      ]);
      _allProducts = results[0] as List<Product>;
      _categories = results[1] as List<String>;
      if (_allProducts.isNotEmpty) {
        _maxPrice = _allProducts
            .map((p) => p.price)
            .reduce((a, b) => a > b ? a : b);
        _priceRange = RangeValues(0, _maxPrice);
      }
      _status = LoadStatus.loaded;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('ApiException: ', '');
      _status = LoadStatus.error;
    }
    notifyListeners();
  }

  Product? getProductById(int id) {
    try {
      return _allProducts.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setSortOption(SortOption option) {
    _sortOption = option;
    notifyListeners();
  }

  void setPriceRange(RangeValues range) {
    _priceRange = range;
    notifyListeners();
  }

  void resetFilters() {
    _selectedCategory = 'All';
    _searchQuery = '';
    _sortOption = SortOption.none;
    _priceRange = RangeValues(0, _maxPrice);
    notifyListeners();
  }

  List<Product> relatedProducts(Product product, {int limit = 6}) {
    return _allProducts
        .where((p) => p.category == product.category && p.id != product.id)
        .take(limit)
        .toList();
  }
}
