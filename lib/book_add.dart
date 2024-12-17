import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'book_data.dart'; 

class AddBookPage extends StatefulWidget {
  final VoidCallback onProductAdded; 

  AddBookPage({required this.onProductAdded});

  @override
  _AddBookPageState createState() => _AddBookPageState();
}

class _AddBookPageState extends State<AddBookPage> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  File? _image;

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<String> _getJsonFilePath() async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/assets/products.json'; 
  }

  Future<List<Product>> _loadProducts() async {
    try {
      return await ProductRepository.loadProducts(); 
    } catch (e) {
      print('Error loading products: $e');
    }
    return [];
  }

  Future<void> _saveProducts(List<Product> products) async {
    try {
      final filePath = await _getJsonFilePath();
      final file = File(filePath);
      await file.create(recursive: true);


      final jsonData = json.encode(products.map((product) => {
            'id': product.id,
            'name': product.name,
            'description': product.description,
            'price': product.price,
            'image': product.image,
            'reviews': product.reviews,
          }).toList());
      await file.writeAsString(jsonData, flush: true);
    } catch (e) {
      print('Error saving products: $e');
    }
  }

  Future<void> _saveBook() async {
    if (_titleController.text.isEmpty ||
        _descriptionController.text.isEmpty ||
        _priceController.text.isEmpty ||
        _image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Заполните все поля и добавьте изображение!')),
      );
      return;
    }

    final appDir = await getApplicationDocumentsDirectory();
    final imageDir = Directory('${appDir.path}/assets/images');
    if (!await imageDir.exists()) {
      await imageDir.create(recursive: true);
    }
    final savedImagePath = '${imageDir.path}/${_image!.path.split('/').last}';
    await _image!.copy(savedImagePath);

    final products = await _loadProducts();
    final newId = products.isNotEmpty ? products.map((p) => p.id).reduce((a, b) => a > b ? a : b) + 1 : 1;

    final newBook = Product(
      id: newId,
      name: _titleController.text,
      description: _descriptionController.text,
      price: double.tryParse(_priceController.text) ?? 0.0,
      image: savedImagePath,
      reviews: [],
    );

    products.add(newBook);
    await _saveProducts(products);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Book successfully added!')),
    );

    _titleController.clear();
    _descriptionController.clear();
    _priceController.clear();
    setState(() {
      _image = null;
    });

    widget.onProductAdded(); 
    Navigator.pop(context); 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Book'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Book Name'),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: 'Decription'),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _priceController,
              decoration: InputDecoration(labelText: 'Price'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16.0),
            Center(
              child: ElevatedButton(
                onPressed: _pickImage,
                child: Text('Upload Image'),
              ),
            ),
            if (_image != null) ...[
              SizedBox(height: 16.0),
              Center(
                child: Image.file(
                  _image!,
                  width: 150,
                  height: 150,
                  fit: BoxFit.cover,
                ),
              ),
            ],
            Spacer(),
            ElevatedButton(
              onPressed: _saveBook,
              child: Text('Add book'),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
