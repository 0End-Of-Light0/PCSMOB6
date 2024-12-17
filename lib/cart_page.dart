import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'book_data.dart';

class CartPage extends StatefulWidget {
  final Map<int, int> cartBooks;
  final void Function(Product) onRemoveFromCart;
  final void Function(Product) onIncreaseQuantity;
  final void Function(Product) onDecreaseQuantity;

  const CartPage({
    Key? key,
    required this.cartBooks,
    required this.onRemoveFromCart,
    required this.onIncreaseQuantity,
    required this.onDecreaseQuantity,
  }) : super(key: key);

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  late Future<Map<int, Product>> _productsFuture;

  @override
  void initState() {
    super.initState();
    _productsFuture = _loadProductsFromJson();
  }

  Future<Map<int, Product>> _loadProductsFromJson() async {
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/assets/products.json';
    final file = File(filePath);

    if (await file.exists()) {
      final jsonData = json.decode(await file.readAsString()) as List;
      final products = jsonData.map((e) => Product.fromJson(e)).toList();
      return {for (var product in products) product.id: product};
    } else {
      return {};
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cart'),
        backgroundColor: Colors.blue,
      ),
      body: FutureBuilder<Map<int, Product>>(
        future: _productsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final productMap = snapshot.data!;
            final cartItems = widget.cartBooks.entries
                .where((entry) => productMap.containsKey(entry.key))
                .toList();

            if (cartItems.isEmpty) {
              return const Center(
                child: Text(
                  'Your cart is empty.',
                  style: TextStyle(fontSize: 18),
                ),
              );
            }

            return ListView.builder(
              itemCount: cartItems.length,
              itemBuilder: (context, index) {
                final item = cartItems[index];
                final product = productMap[item.key]!;
                final quantity = item.value;

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  child: ListTile(
                    leading: _buildProductImage(product.image),
                    title: Text(
                      product.name,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Price: \$${product.price.toStringAsFixed(2)}'),
                        Text('Quantity: $quantity'),
                        Text('Total: \$${(product.price * quantity).toStringAsFixed(2)}'),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove),
                          onPressed: () => widget.onDecreaseQuantity(product),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () => widget.onIncreaseQuantity(product),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => widget.onRemoveFromCart(product),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          } else {
            return const Center(child: Text('Failed to load cart items.'));
          }
        },
      ),
    );
  }

  Widget _buildProductImage(String imagePath) {
    final file = File(imagePath);
    if (file.existsSync()) {
      return Image.file(
        file,
        width: 50,
        height: 50,
        fit: BoxFit.cover,
      );
    } else {
      return Image.asset(
        imagePath,
        width: 50,
        height: 50,
        fit: BoxFit.cover,
      );
    }
  }
}
