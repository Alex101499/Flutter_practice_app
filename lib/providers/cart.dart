import 'package:flutter/material.dart';

class CartItem {
  final String id;
  final String title;
  final int quantity;
  final double price;

  CartItem(
    this.id,
    this.title,
    this.quantity,
    this.price,
  );
}

class Cart with ChangeNotifier {
  var cont = 0;
  Map<String, CartItem> _items = {};

  Map<String, CartItem> get item {
    return {..._items};
  }

  int get itemCount {
    return _items == null ? 0 : _items.length;
  }

  int get quantityCount {
    int total = 0;
    _items.forEach((key, cartItem) {
      total += cartItem.quantity;
    });
    return total;
  }

  double get totalAmount {
    var total = 0.0;
    _items.forEach((key, cartItem) {
      total += cartItem.price * cartItem.quantity;
    });
    return total;
  }

  void addItem(String productId, double price, String title) {
    if (_items.containsKey(productId)) {
      _items.update(
          productId.toString(),
          (existingCartItem) => CartItem(
                existingCartItem.id,
                existingCartItem.title,
                existingCartItem.quantity + 1,
                existingCartItem.price,
              ));
      cont++;
    } else {
      _items.putIfAbsent(
          productId.toString(),
          () => CartItem(
                productId,
                title,
                1,
                price,
              ));
      cont++;
    }
    print(cont);
    notifyListeners();
  }

  void removeItem(String productId) {
    _items.remove(productId);
    notifyListeners();
  }

  void clear() {
    _items = {};
    notifyListeners();
  }

  void removeSingleItem(String productId) {
    if (!_items.containsKey(productId)) {
      return;
    }
    if (_items[productId].quantity > 1) {
      _items.update(
          productId,
          (existingCartItem) => CartItem(
                existingCartItem.id,
                existingCartItem.title,
                existingCartItem.quantity - 1,
                existingCartItem.price,
              ));
    } else {
      _items.remove(productId);
    }
    notifyListeners();
  }
}
