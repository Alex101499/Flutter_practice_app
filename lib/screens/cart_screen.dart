import 'package:provider/provider.dart';
import '../screens/order_screen.dart';

import '../providers/cart.dart' show Cart;
import '../providers/orders.dart';

import 'package:flutter/material.dart';
import '../widgets/card_item.dart';

class CartScreen extends StatelessWidget {
  static const routeName = '/cart';
  @override
  Widget build(BuildContext context) {
    final cartData = Provider.of<Cart>(context);
    print(cartData.quantityCount);
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Tu Carrito',
        ),
      ),
      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.all(15),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total',
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                  Chip(
                    label: Text(
                      '\$${cartData.totalAmount.toStringAsFixed(2)}',
                      style: TextStyle(
                        color:
                            Theme.of(context).primaryTextTheme.headline6.color,
                      ),
                    ),
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                  OrderButton(cartData: cartData)
                ],
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Expanded(
              child: ListView.builder(
            itemBuilder: (ctx, index) => CartItem(
              id: cartData.item.values.toList()[index].id,
              productId: cartData.item.keys.toList()[index],
              price: cartData.item.values.toList()[index].price,
              quantity: cartData.item.values.toList()[index].quantity,
              title: cartData.item.values.toList()[index].title,
            ),
            itemCount: cartData.itemCount,
          ))
        ],
      ),
    );
  }
}

class OrderButton extends StatefulWidget {
  const OrderButton({
    Key key,
    @required this.cartData,
  }) : super(key: key);

  final Cart cartData;

  @override
  State<OrderButton> createState() => _OrderButtonState();
}

class _OrderButtonState extends State<OrderButton> {
  var _isLoading = false;
  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      child: _isLoading
          ? const CircularProgressIndicator()
          : const Text(
              'Ordena Ya',
            ),
      onPressed: (widget.cartData.totalAmount <= 0 || _isLoading)
          ? null
          : () async {
              setState(() {
                _isLoading = true;
              });
              await Provider.of<Orders>(context, listen: false).addOrder(
                widget.cartData.item.values.toList(),
                widget.cartData.totalAmount,
              );
              setState(() {
                _isLoading = false;
              });
              widget.cartData.clear();
              Navigator.of(context).pushNamed(OrderScreen.routeName);
            },
    );
  }
}
