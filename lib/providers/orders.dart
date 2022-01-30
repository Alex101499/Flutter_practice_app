import 'package:flutter/material.dart';
import '../providers/cart.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime dateTime;

  OrderItem(
      {@required this.id,
      @required this.amount,
      @required this.products,
      @required this.dateTime});
}

class Orders with ChangeNotifier {
  List<OrderItem> _orders = [];
  final String authToken;
  final String userId;

  Orders(this.authToken, this.userId, this._orders);

  List<OrderItem> get order {
    return [..._orders];
  }

  Future<void> fetchAndSetOrders() async {
    final url = Uri.parse(
        'https://flutter-shop-app-b4de7-default-rtdb.firebaseio.com/orders/$userId.json?auth=$authToken');
    try {
      final response = await http.get(url);
      final List<OrderItem> loadOrders = [];
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      extractedData == null
          ? 0
          : extractedData.forEach((orderId, orderData) {
              loadOrders.add(OrderItem(
                id: orderId,
                amount: orderData['amount'],
                products: (orderData['products'] as List<dynamic>)
                    .map(
                      (item) => CartItem(
                        item['id'],
                        item['title'],
                        item['quantity'],
                        item['price'],
                      ),
                    )
                    .toList(),
                dateTime: DateTime.parse(orderData['dateTime']),
              ));
              _orders = loadOrders.reversed.toList();
              notifyListeners();
            });
    } catch (e) {
      rethrow;
    }
  }

  Future<void> addOrder(List<CartItem> cartProducts, double total) async {
    final url = Uri.parse(
        'https://flutter-shop-app-b4de7-default-rtdb.firebaseio.com/orders/$userId.json?auth=$authToken');
    final timestamp = DateTime.now();
    try {
      final response = await http.post(url,
          body: json.encode({
            'amount': total,
            'dateTime': timestamp.toIso8601String(),
            'products': cartProducts
                .map((cartItem) => {
                      'id': cartItem.id,
                      'title': cartItem.title,
                      'quantity': cartItem.quantity,
                      'price': cartItem.price,
                    })
                .toList()
          }));
      _orders.insert(
          0,
          OrderItem(
            id: json.decode(response.body)['name'],
            amount: total,
            dateTime: DateTime.now(),
            products: cartProducts,
          ));

      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }
}
