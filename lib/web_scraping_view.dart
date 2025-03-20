// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class Product {
  final String? productName;
  final String? productPrice;
  final String? productImage;
  final String? productQuantity;

  Product({
    this.productName,
    this.productPrice,
    this.productImage,
    this.productQuantity,
  });

  factory Product.fromMap(Map<String, dynamic> json) => Product(
        productName: json["name"],
        productPrice: json["price"],
        productImage: json["image"],
        productQuantity: json["quantity"],
      );

  factory Product.fromJson(String source) =>
      Product.fromMap(json.decode(source) as Map<String, dynamic>);
}

class WebScrapingScreen extends StatefulWidget {
  const WebScrapingScreen({super.key});

  @override
  State<WebScrapingScreen> createState() => _WebScrapingScreenState();
}

class _WebScrapingScreenState extends State<WebScrapingScreen> {
  late final WebViewController _controller;

  List<Product> productsList = [];

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel(
        'ProductData',
        onMessageReceived: (JavaScriptMessage message) {
          _parseProductData(message.message);
        },
      )
      ..loadRequest(Uri.parse('https://www.amazon.eg/'));
  }

  /// دالة لتحليل البيانات المرسلة من JavaScript
  void _parseProductData(String jsonString) {
    Product product = Product();

    List json = jsonDecode(jsonString);
    productsList = [];
    for (var element in json) {
      product = Product.fromMap(element);
      productsList.add(product);
    }
    try {
      setState(() {});
    } catch (e) {
      log("خطأ في تحليل بيانات المنتج: $e");
    }
  }

  /// دالة تقوم بتشغيل كود جافا سكريبت داخل صفحة الويب لاستخراج بيانات المنتج
  void _extractProductData() {
    const jsCode = '''
  (function() {
    try {
      var products = [];
      var productElements = document.querySelectorAll('.sc-list-item'); // حدد العنصر الأساسي لكل منتج في القائمة

      productElements.forEach((product) => {
        var title = product.querySelector('.a-truncate-cut') ? product.querySelector('.a-truncate-cut').innerText : 'لا يوجد اسم';
        var price = product.querySelector('.a-price-whole') ? product.querySelector('.a-price-whole').innerText : 'غير متاح';
        var img = product.querySelector('.sc-product-image') ? product.querySelector('.sc-product-image').src : '';
        var quantityElement = product.querySelector('[data-a-selector="value"]');
        var quantity = quantityElement ? quantityElement.innerText.trim() : 'لا توجد قيمة';

        products.push({
          "name": title,
          "price": price,
          "image": img,
          "quantity": quantity
        });
      });

      // إرسال القائمة بالكامل إلى فلاتر عبر القناة
      ProductData.postMessage(JSON.stringify(products));
    } catch (e) {
      console.log('خطأ في جلب البيانات:', e);
    }
  })();
''';

    _controller.runJavaScript(jsCode);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("متجر المنتجات"),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _extractProductData,
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: WebViewWidget(controller: _controller),
          ),
          Container(
            color: Colors.amberAccent,
            height: 500,
            child: ListView.builder(
              itemCount: productsList.length,
              itemBuilder: (context, index) {
                return ProductItem(product: productsList[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ProductItem extends StatelessWidget {
  const ProductItem({
    super.key,
    required this.product,
  });

  final Product product;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      color: const Color.fromARGB(255, 196, 46, 46),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("اسم المنتج: ${product.productName}",
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          Text("السعر: ${product.productPrice}",
              style: const TextStyle(fontSize: 16, color: Colors.green)),
          Text("العدد: ${product.productQuantity}",
              style: const TextStyle(fontSize: 16, color: Colors.green)),
          const SizedBox(height: 5),
          if (product.productImage != null)
            Image.network(product.productImage!, height: 100),
        ],
      ),
    );
  }
}
