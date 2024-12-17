import 'dart:io';
import 'package:flutter/material.dart';
import 'book_data.dart';
import 'book_detail.dart';
import 'book_add.dart';

class BookListPage extends StatefulWidget {
  final Map<int, bool> favoriteStatus;
  final List<Product> favoriteBooks;
  final void Function(Product) onFavoriteToggle;
  final Map<int, int> cartBooks; // Cart books list
  final void Function(Product) onAddToCart; // Add to cart method
  final void Function(Product) onRemoveFromCart; // Remove from cart method
  final void Function(Product) onIncreaseQuantity; // Increase quantity method
  final void Function(Product) onDecreaseQuantity; // Decrease quantity method

  const BookListPage({
    Key? key,
    required this.favoriteStatus,
    required this.favoriteBooks,
    required this.onFavoriteToggle,
    required this.cartBooks, // Receive the cartBooks list
    required this.onAddToCart, // Receive the add to cart method
    required this.onRemoveFromCart, // Receive the remove from cart method
    required this.onIncreaseQuantity, // Receive increase quantity method
    required this.onDecreaseQuantity, // Receive decrease quantity method
  }) : super(key: key);

  @override
  _BookListPageState createState() => _BookListPageState();
}

class _BookListPageState extends State<BookListPage> {
  late Future<List<Product>> _productsFuture;

  @override
  void initState() {
    super.initState();
    _productsFuture = ProductRepository.loadProducts();
  }

  void _refreshProductList() {
    setState(() {
      _productsFuture = ProductRepository.loadProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('e-Book List'),
        backgroundColor: Colors.blue,
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20),
      ),
      body: FutureBuilder<List<Product>>(
        future: _productsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          } else {
            final products = snapshot.data ?? [];
            return GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.7,
              ),
              itemCount: products.length,
              padding: const EdgeInsets.all(10),
              itemBuilder: (context, index) {
                final product = products[index];
                final isFavorite = widget.favoriteStatus[product.id] ?? false;
                // Извлекаем количество товара из cartBooks по ID
                final cartQuantity = widget.cartBooks[product.id] ?? 0;

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BookDetailPage(
                          product: product,
                          onProductDeleted: _refreshProductList,
                        ),
                      ),
                    );
                  },
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
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(
                                isFavorite ? Icons.favorite : Icons.favorite_border,
                                color: isFavorite ? Colors.red : null,
                              ),
                              onPressed: () => widget.onFavoriteToggle(product),
                            ),
                            if (cartQuantity > 0)
                              Row(
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.remove),
                                    onPressed: () => widget.onDecreaseQuantity(product),
                                  ),
                                  Text('$cartQuantity'),
                                  IconButton(
                                    icon: Icon(Icons.add),
                                    onPressed: () => widget.onIncreaseQuantity(product),
                                  ),
                                ],
                              )
                            else
                              IconButton(
                                icon: Icon(Icons.add_shopping_cart),
                                onPressed: () => widget.onAddToCart(product),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddBookPage(
                onProductAdded: _refreshProductList,
              ),
            ),
          );
        },
        child: const Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
    );
  }

  Widget _buildProductImage(String imagePath) {
    final file = File(imagePath);
    if (file.existsSync()) {
      return Image.file(
        file,
        fit: BoxFit.cover,
      );
    } else {
      return Image.asset(
        imagePath,
        fit: BoxFit.cover,
      );
    }
  }
}
