import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import 'book_data.dart';

class BookDetailPage extends StatelessWidget {
  final Product product;
  final VoidCallback onProductDeleted; 

  BookDetailPage({required this.product, required this.onProductDeleted});

  Future<String> _getJsonFilePath() async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/assets/products.json'; 
  }

  Future<List<Product>> _loadProducts() async {
    return await ProductRepository.loadProducts();
  }

  Future<void> _saveProducts(List<Product> products) async {
    try {
      final filePath = await _getJsonFilePath();
      final file = File(filePath);

      final jsonData = jsonEncode(products.map((p) => {
            'id': p.id,
            'name': p.name,
            'description': p.description,
            'price': p.price,
            'image': p.image,
            'reviews': p.reviews,
          }).toList());

      await file.writeAsString(jsonData, flush: true);
    } catch (e) {
      print('Error saving products: $e');
    }
  }

  Future<void> _deleteProduct(BuildContext context) async {
    final products = await _loadProducts();

    products.removeWhere((p) => p.id == product.id);

    await _saveProducts(products);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${product.name} successfully deleted')),
    );

    onProductDeleted();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(product.name),
        backgroundColor: Colors.blue,
        titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            color: Colors.white,
            onPressed: () => _deleteProduct(context),
            tooltip: 'Delete book',
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.file(File(product.image), height: 200, fit: BoxFit.cover),
            SizedBox(height: 16),
            Text(
              product.description,
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 16),
            Text(
              'Price: \$${product.price.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              'Reviews:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            ...product.reviews.map((review) => Text('- $review')).toList(),
          ],
        ),
      ),
    );
  }
}
