import 'package:flutter/foundation.dart';
import '../models/cart_item.dart';
import '../models/product.dart';
import '../services/storage_service.dart';

class CartProvider extends ChangeNotifier {
  final StorageService _storageService;

  CartProvider({StorageService? storageService})
      : _storageService = storageService ?? StorageService();

  final List<CartItem> _items = [];
  static const double shippingFee = 5.99;
  static const double taxRate = 0.08;

  List<CartItem> get items => List.unmodifiable(_items);

  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);

  double get subtotal =>
      _items.fold(0.0, (sum, item) => sum + item.totalPrice);

  double get tax => subtotal * taxRate;

  double get shipping => _items.isEmpty ? 0.0 : shippingFee;

  double get total => subtotal + tax + shipping;

  bool get isEmpty => _items.isEmpty;

  Future<void> loadCart() async {
    final saved = await _storageService.getCart();
    _items
      ..clear()
      ..addAll(saved);
    notifyListeners();
  }

  Future<void> _persist() async {
    await _storageService.saveCart(_items);
  }

  int _indexOf(int productId) =>
      _items.indexWhere((item) => item.product.id == productId);

  void addToCart(Product product, {int quantity = 1}) {
    final index = _indexOf(product.id);
    if (index >= 0) {
      _items[index].quantity += quantity;
    } else {
      _items.add(CartItem(product: product, quantity: quantity));
    }
    _persist();
    notifyListeners();
  }

  void removeFromCart(int productId) {
    _items.removeWhere((item) => item.product.id == productId);
    _persist();
    notifyListeners();
  }

  void incrementQuantity(int productId) {
    final index = _indexOf(productId);
    if (index >= 0) {
      _items[index].quantity++;
      _persist();
      notifyListeners();
    }
  }

  void decrementQuantity(int productId) {
    final index = _indexOf(productId);
    if (index >= 0) {
      if (_items[index].quantity > 1) {
        _items[index].quantity--;
      } else {
        _items.removeAt(index);
      }
      _persist();
      notifyListeners();
    }
  }

  bool isInCart(int productId) => _indexOf(productId) >= 0;

  int quantityOf(int productId) {
    final index = _indexOf(productId);
    return index >= 0 ? _items[index].quantity : 0;
  }

  void clearCart() {
    _items.clear();
    _persist();
    notifyListeners();
  }
}
