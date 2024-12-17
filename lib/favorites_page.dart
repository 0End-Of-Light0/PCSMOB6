import 'dart:io';
import 'package:flutter/material.dart';
import 'book_data.dart';

class FavoritesPage extends StatelessWidget {
  final List<Product> favoriteBooks;
  final void Function(Product) onFavoriteTapped;

  const FavoritesPage({
    Key? key,
    required this.favoriteBooks,
    required this.onFavoriteTapped,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
        backgroundColor: Colors.blue,
      ),
      body: favoriteBooks.isEmpty
          ? const Center(
              child: Text(
                'Your favorite books will appear here.',
                style: TextStyle(fontSize: 18),
              ),
            )
          : GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // Количество столбцов
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.7, // Соотношение сторон плитки
              ),
              itemCount: favoriteBooks.length,
              padding: const EdgeInsets.all(10),
              itemBuilder: (context, index) {
                final product = favoriteBooks[index];
                return GestureDetector(
                  onTap: () => onFavoriteTapped(product),
                  child: Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                            child: _buildProductImage(product.image),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 5),
                              Text(
                                '\$${product.price.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildProductImage(String imagePath) {
    final file = File(imagePath);
    if (file.existsSync()) {
      // Если файл существует в локальном хранилище, используем его.
      return Image.file(
        file,
        fit: BoxFit.cover,
      );
    } else {
      // Если файл не найден, используем изображение из ассетов.
      return Image.asset(
        imagePath,
        fit: BoxFit.cover,
      );
    }
  }
}
