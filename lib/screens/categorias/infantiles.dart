import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class InfantilesScreen extends StatefulWidget {
  const InfantilesScreen({super.key});

  @override
  State<InfantilesScreen> createState() => _InfantilesScreenState();
}

class _InfantilesScreenState extends State<InfantilesScreen> {
  List<dynamic> _products = [];
  bool _isLoading = true;
  String? _error;

  static const Color _accentColor = Color(0xFF1A5C3A);

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final data = await ApiService.getProductsByCategory('infantiles');
      if (mounted) setState(() => _products = data);
    } catch (_) {
      if (mounted) setState(() => _error = 'No se pudieron cargar los productos');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: _accentColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Infantiles',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: _accentColor),
      );
    }
    if (_error != null) {
      return _ErrorState(message: _error!, onRetry: _fetchProducts);
    }
    if (_products.isEmpty) {
      return _EmptyState(
        icon: Icons.child_care_outlined,
        message: 'No hay productos disponibles',
        onRetry: _fetchProducts,
      );
    }
    return RefreshIndicator(
      color: _accentColor,
      onRefresh: _fetchProducts,
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio: 0.72,
        ),
        itemCount: _products.length,
        itemBuilder: (context, i) => _ProductCard(
          product: _products[i],
          accentColor: _accentColor,
        ),
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final dynamic product;
  final Color accentColor;

  const _ProductCard({required this.product, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    final name = product['name']?.toString() ?? 'Producto';
    final price = product['price']?.toString() ?? '0.00';
    final imageUrl = product['image_url']?.toString() ?? '';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(14)),
              child: imageUrl.isNotEmpty
                  ? Image.network(imageUrl,
                      fit: BoxFit.cover, width: double.infinity,
                      errorBuilder: (_, __, ___) =>
                          _PlaceholderImage(color: accentColor))
                  : _PlaceholderImage(color: accentColor),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A2E),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '\$$price',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: accentColor,
                      ),
                    ),
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: accentColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.add,
                          color: Colors.white, size: 18),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PlaceholderImage extends StatelessWidget {
  final Color color;
  const _PlaceholderImage({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color.withOpacity(0.1),
      child: Center(
        child: Icon(Icons.child_care_outlined,
            color: color.withOpacity(0.4), size: 48),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline,
              color: Color(0xFFD32F2F), size: 48),
          const SizedBox(height: 16),
          Text(message,
              style: const TextStyle(
                  color: Color(0xFF6B6B6B), fontSize: 14)),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1A5C3A),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  final VoidCallback onRetry;

  const _EmptyState(
      {required this.icon, required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: const Color(0xFFBDBDBD), size: 56),
          const SizedBox(height: 16),
          Text(message,
              style: const TextStyle(
                  color: Color(0xFF6B6B6B), fontSize: 14)),
          const SizedBox(height: 20),
          TextButton(
            onPressed: onRetry,
            child: const Text('Actualizar',
                style: TextStyle(color: Color(0xFF1A5C3A))),
          ),
        ],
      ),
    );
  }
}
