import 'package:flutter/material.dart';
import 'book_detail.dart';
import 'book_list.dart';
import 'favorites_page.dart';
import 'profile_page.dart';
import 'cart_page.dart'; // Добавляем страницу корзины
import 'book_data.dart';

void main() {
  runApp(MyApp());
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'e-Book App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  final List<Product> _favoriteBooks = [];
  final Map<int, bool> _favoriteStatus = {};
  final Map<int, int> _cartBooks = {}; // Store product quantities in cart

  // Future variable for loading products
  late Future<List<Product>> _productsFuture;

  // Load products in initState
  @override
  void initState() {
    super.initState();
    _productsFuture = _loadProducts();
  }

  // Method to simulate loading products (Replace this with actual data source)
  Future<List<Product>> _loadProducts() async {
    // Simulating loading products (replace with actual data fetching logic)
    await Future.delayed(Duration(seconds: 2)); // Simulate a delay
    return [
      Product(id: 1, name: 'Book 1', description: 'Description 1', price: 10.0, image: 'image_url_1', reviews: []),
      Product(id: 2, name: 'Book 2', description: 'Description 2', price: 12.0, image: 'image_url_2', reviews: []),
      Product(id: 3, name: 'Book 3', description: 'Description 3', price: 15.0, image: 'image_url_3', reviews: []),
    ];
  }

  // Methods to manage cart and favorites
  void _increaseQuantity(Product product) {
    setState(() {
      _cartBooks[product.id] = (_cartBooks[product.id] ?? 0) + 1;
    });
  }

  void _decreaseQuantity(Product product) {
    setState(() {
      if (_cartBooks[product.id]! > 1) {
        _cartBooks[product.id] = _cartBooks[product.id]! - 1;
      } else {
        _cartBooks.remove(product.id);
      }
    });
  }

  void _toggleFavorite(Product product) {
    setState(() {
      final isFavorite = _favoriteStatus[product.id] ?? false;
      _favoriteStatus[product.id] = !isFavorite;

      if (!isFavorite) {
        _favoriteBooks.add(product);
      } else {
        _favoriteBooks.removeWhere((item) => item.id == product.id);
      }
    });
  }

  void _addToCart(Product product) {
    setState(() {
      _cartBooks[product.id] = (_cartBooks[product.id] ?? 0) + 1;
    });
  }

  void _removeFromCart(Product product) {
    setState(() {
      _cartBooks.remove(product.id);
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _pages = [
      FutureBuilder<List<Product>>(
        future: _productsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No products available.'));
          } else {

            return BookListPage(
              favoriteStatus: _favoriteStatus,
              onFavoriteToggle: _toggleFavorite,
              favoriteBooks: _favoriteBooks,
              cartBooks: _cartBooks,
              onAddToCart: _addToCart,
              onRemoveFromCart: _removeFromCart,
              onDecreaseQuantity: _decreaseQuantity,
              onIncreaseQuantity: _increaseQuantity,
            );
          }
        },
      ),
      FavoritesPage(
        favoriteBooks: _favoriteBooks,
        onFavoriteTapped: (product) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BookDetailPage(
                product: product,
                onProductDeleted: () {},
              ),
            ),
          );
        },
      ),
      FutureBuilder<List<Product>>(
        future: _productsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No products available.'));
          } else {
            //final products = snapshot.data!;

            return CartPage(
              cartBooks: _cartBooks,
              onRemoveFromCart: _removeFromCart,
              onIncreaseQuantity: _increaseQuantity,
              onDecreaseQuantity: _decreaseQuantity,
              //allProducts: products, // Pass list of all products here
            );
          }
        },
      ),
      ProfilePage(),
    ];

    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Books',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Cart',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
