import 'package:flutter/widgets.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import '../models/product.dart';
import '../data.dart';

class Products with ChangeNotifier {
  List<Product> _item = [];

  var _showFavoritesOnly = false;
  List<Product> get items {
    if (_showFavoritesOnly) {
      return _item.where((prodItem) => prodItem.isFavorite).toList();
    }
    return [..._item]; //copia del original
  }

  final String authToken;
  final String userId;
  Products(this.authToken, this.userId, this._item);

  List<Product> get favoriteItems {
    return _item.where((prodItem) => prodItem.isFavorite).toList();
  }

  Future<void> fetchAndSetProducts([bool filterByUser = false]) async {
    final filterString =
        filterByUser ? 'orderBy="creatorId"&equalTo="$userId"' : '';
    var url = Uri.parse(
      'https://flutter-shop-app-b4de7-default-rtdb.firebaseio.com/products.json?auth=$authToken&$filterString',
    );
    try {
      final response = await http.get(url);
      final extractData = json.decode(response.body) as Map<String, dynamic>;
      if (extractData == null) {
        return;
      }
      url = Uri.parse(
          'https://flutter-shop-app-b4de7-default-rtdb.firebaseio.com/userFavorities/$userId.json?auth=$authToken');
      final favoriteResponse = await http.get(url);
      final favoriteData = json.decode(favoriteResponse.body);
      List<Product> loadedProducts = [];
      extractData.forEach((prodId, prodData) {
        loadedProducts.add(Product(
          id: prodId,
          title: prodData['title'],
          description: prodData['description'],
          price: prodData['price'],
          isFavorite:
              favoriteData == null ? false : favoriteData[prodId] ?? false,
          imageUrl: prodData['imageUrl'],
        ));
      });
      _item = loadedProducts;
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> addProduct(Product product) async {
    final url = Uri.parse(
      'https://flutter-shop-app-b4de7-default-rtdb.firebaseio.com/products.json?auth=$authToken',
    );
    try {
      final response = await http.post(url,
          body: json.encode({
            'title': product.title,
            'description': product.description,
            'price': product.price,
            'imageUrl': product.imageUrl,
            'creatorId': userId,
          }));
      final newProduct = Product(
          id: json.decode(response.body)['name'],
          title: product.title,
          price: product.price,
          description: product.description,
          imageUrl: product.imageUrl);
      _item.add(newProduct);
      notifyListeners();
    } catch (error) {
      rethrow;
    }

    //_item.add(value);
  }

  Future<void> updateProduct(String id, Product newProduct) async {
    final prodIndex = _item.indexWhere((prod) => prod.id == id);
    if (prodIndex >= 0) {
      final url = Uri.parse(
          'https://flutter-shop-app-b4de7-default-rtdb.firebaseio.com/products/$id.json?auth=$authToken');
      try {
        await http.patch(
          url,
          body: json.encode({
            'title': newProduct.title,
            'description': newProduct.description,
            'price': newProduct.price,
            'imageUrl': newProduct.imageUrl,
          }),
        );
        _item[prodIndex] = newProduct;
        notifyListeners();
      } catch (e) {
        rethrow;
      }
    }
  }

  void deleteProduct(String id) {
    final url = Uri.parse(
        'https://flutter-shop-app-b4de7-default-rtdb.firebaseio.com/products/$id.json?auth=$authToken');
    final existingProductId = _item.indexWhere((prod) => prod.id == id);
    var existingProduct = _item[existingProductId];

    http.delete(url).then((_) {
      existingProduct = null;
    }).catchError((error) {
      _item.insert(existingProductId, existingProduct);
    });

    _item.removeWhere((prod) => prod.id == id);
    notifyListeners();
  }

  Product findById(String id) {
    return _item.firstWhere((item) => item.id == id);
  }
}
