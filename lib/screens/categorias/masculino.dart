import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../services/auth_state.dart';
import '../../widgets/buscador.dart';
import '../../widgets/categorias_horizontal.dart';
import '../../widgets/banner_slider.dart';
import '../../widgets/grid_productos.dart';
import '../cart.dart';
import '../login.dart';

class MasculinoScreen extends StatefulWidget {
  const MasculinoScreen({super.key});

  @override
  State<MasculinoScreen> createState() => _MasculinoScreenState();
}

class _MasculinoScreenState extends State<MasculinoScreen> {
  List<dynamic> _products = [];
  bool _isLoading = true;
  String? _error;

  static const Color _accentColor = Color(0xFF1A3A5C);

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
      final data = await ApiService.getProductsByCategory('masculino');
      if (mounted) setState(() => _products = data);
    } catch (_) {
      if (mounted)
        setState(() => _error = 'No se pudieron cargar los productos');
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
          'Masculino',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined, color: Colors.white),
            onPressed: () {
              if (!authState.isLoggedIn) {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()));
              } else {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const CartScreen()));
              }
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        color: _accentColor,
        onRefresh: _fetchProducts,
        child: CustomScrollView(
          slivers: [
            const SliverToBoxAdapter(
              child: Column(
                children: [
                  Buscador(),
                  CategoriasHorizontal(),
                  BannerSlider(),
                ],
              ),
            ),
            GridProductos(
              products: _products,
              isLoading: _isLoading,
              error: _error,
              onRetry: _fetchProducts,
              accentColor: _accentColor,
            ),
          ],
        ),
      ),
    );
  }
}
