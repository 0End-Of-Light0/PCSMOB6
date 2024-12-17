import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

Future<String> _getJsonFilePath() async {
  final directory = await getApplicationDocumentsDirectory();
  return '${directory.path}/assets/products.json';
}

class Product {
  final int id;
  final String name;
  final String description;
  final double price;
  final String image;
  final List<String> reviews;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.image,
    required this.reviews,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: json['price'].toDouble(),
      image: json['image'],
      reviews: List<String>.from(json['reviews']),
    );
  }
}

class ProductRepository {
  static Future<List<Product>> loadProducts() async {
    try {
      final filePath = await _getJsonFilePath();
      final file = File(filePath);

      if (await file.exists()) {
        final data = await file.readAsString();
        final List<dynamic> productsJson = jsonDecode(data);
        return productsJson.map((json) => Product.fromJson(json)).toList();
      } else {
        final data = await rootBundle.loadString('assets/products.json');
        final List<dynamic> productsJson = jsonDecode(data);

        await file.writeAsString(jsonEncode(productsJson), flush: true);
        return productsJson.map((json) => Product.fromJson(json)).toList();
      }
    } catch (e) {
      print('Error loading products: $e');
      return [];
    }
  }
}
