import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart'; // For date formatting

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Products',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ProductListScreen(),
    );
  }
}

class ProductListScreen extends StatefulWidget {
  @override
  _ProductListScreenState createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  List<Map<String, dynamic>> products = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProducts(); // Fetch products when the screen is loaded
  }

  Future<void> _fetchProducts() async {
    try {
      final response = await http.get(Uri.parse('http://35.73.30.144:2008/api/v1/ReadProduct'));
      if (response.statusCode == 200) {
        // Parse the response as a Map
        final Map<String, dynamic> responseData = json.decode(response.body);

        // Extract the list of products from the Map
        final List<dynamic> productList = responseData['data'] ?? []; // Replace 'data' with the actual key

        // Update the state with the list of products
        setState(() {
          products = List<Map<String, dynamic>>.from(productList);
          isLoading = false; // Data fetching is complete
        });
      } else {
        throw Exception('Failed to load products');
      }
    } catch (e) {
      print('Error fetching products: $e');
      setState(() {
        isLoading = false; // Stop loading in case of error
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load products. Please try again later.')),
      );
    }
  }

  void _showCreateProductDialog() {
    final _formKey = GlobalKey<FormState>();
    final _nameController = TextEditingController();
    final _imgController = TextEditingController();
    final _qtyController = TextEditingController();
    final _unitPriceController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Create Product'),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(labelText: 'Product Name'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a product name';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _imgController,
                    decoration: InputDecoration(labelText: 'Image URL'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter an image URL';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _qtyController,
                    decoration: InputDecoration(labelText: 'Quantity'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a quantity';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _unitPriceController,
                    decoration: InputDecoration(labelText: 'Unit Price'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a unit price';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  // Generate Product Code using current timestamp
                  final productCode = DateTime.now().millisecondsSinceEpoch;

                  // Create a product with user input and auto-generated Product Code
                  final product = {
                    'ProductName': _nameController.text,
                    'ProductCode': productCode, // Auto-generated
                    'Img': _imgController.text,
                    'Qty': int.parse(_qtyController.text),
                    'UnitPrice': double.parse(_unitPriceController.text),
                    'TotalPrice': int.parse(_qtyController.text) * double.parse(_unitPriceController.text),
                  };

                  // Call API to create the product
                  _createProduct(product).then((_) {
                    Navigator.of(context).pop(); // Close the dialog
                  });
                }
              },
              child: Text('Create'),
            ),
          ],
        );
      },
    );
  }

  void _showEditProductDialog(Map<String, dynamic> product) {
    final _formKey = GlobalKey<FormState>();
    final _nameController = TextEditingController(text: product['ProductName']);
    final _imgController = TextEditingController(text: product['Img']);
    final _qtyController = TextEditingController(text: product['Qty'].toString());
    final _unitPriceController = TextEditingController(text: product['UnitPrice'].toString());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Product'),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(labelText: 'Product Name'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a product name';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _imgController,
                    decoration: InputDecoration(labelText: 'Image URL'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter an image URL';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _qtyController,
                    decoration: InputDecoration(labelText: 'Quantity'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a quantity';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _unitPriceController,
                    decoration: InputDecoration(labelText: 'Unit Price'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a unit price';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  // Update the product with user input
                  final updatedProduct = {
                    'ProductName': _nameController.text,
                    'ProductCode': product['ProductCode'], // Keep the same Product Code
                    'Img': _imgController.text,
                    'Qty': int.parse(_qtyController.text),
                    'UnitPrice': double.parse(_unitPriceController.text),
                    'TotalPrice': int.parse(_qtyController.text) * double.parse(_unitPriceController.text),
                  };

                  // Call API to update the product
                  _updateProduct(product['_id'], updatedProduct).then((_) {
                    Navigator.of(context).pop(); // Close the dialog
                  });
                }
              },
              child: Text('Update'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _createProduct(Map<String, dynamic> product) async {
    try {
      final response = await http.post(
        Uri.parse('http://35.73.30.144:2008/api/v1/CreateProduct'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(product),
      );
      if (response.statusCode == 200) {
        // Refresh the product list after creation
        _fetchProducts();
      } else {
        throw Exception('Failed to create product. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error creating product: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create product. Please try again later.')),
      );
    }
  }

  Future<void> _updateProduct(String id, Map<String, dynamic> product) async {
    try {
      final response = await http.post(
        Uri.parse('http://35.73.30.144:2008/api/v1/UpdateProduct/$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(product),
      );
      if (response.statusCode == 200) {
        // Refresh the product list after update
        _fetchProducts();
      } else {
        throw Exception('Failed to update product. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error updating product: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update product. Please try again later.')),
      );
    }
  }

  Future<void> _deleteProduct(String id) async {
    try {
      print('Deleting product with ID: $id'); // Debug log
      final response = await http.delete(
        Uri.parse('http://35.73.30.144:2008/api/v1/DeleteProduct/$id'),
      );

      if (response.statusCode == 200) {
        // Refresh the product list after deletion
        _fetchProducts();
      } else {
        // Handle non-200 status codes
        print('Failed to delete product. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception('Failed to delete product. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error deleting product: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete product. Please try again later.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Products',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue,
        elevation: 0,
        toolbarHeight: 80,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator()) // Show loading indicator
          : products.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_circle_outline,
              size: 64,
              color: Colors.blue,
            ),
            SizedBox(height: 16),
            Text(
              'No products available',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _showCreateProductDialog, // Open dialog to create product
              child: Text('Add Product'),
            ),
          ],
        ),
      )
          : ListView.builder(
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return Container(
            margin: EdgeInsets.all(8.0),
            padding: EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                // Product Image
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.0),
                    image: DecorationImage(
                      image: NetworkImage(product['Img'] ?? 'https://via.placeholder.com/80'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(width: 16),
                // Product Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product['ProductName'] ?? 'No Name',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Code: ${product['ProductCode']}',
                        style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                      ),
                      Text(
                        'Price: \$${product['UnitPrice'] ?? '0.00'} | Qty: ${product['Qty'] ?? '0'}',
                        style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                      ),
                    ],
                  ),
                ),
                // Edit and Delete Buttons
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit, color: Colors.blue),
                      onPressed: () {
                        _showEditProductDialog(product); // Open edit dialog
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        _deleteProduct(product['_id']); // Delete product
                      },
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateProductDialog, // Open dialog to create product
        child: Icon(Icons.add),
      ),
    );
  }
}