import 'package:flutter/material.dart';
import 'categorias/masculino.dart';
import 'categorias/femenino.dart';
import 'categorias/infantiles.dart';
import 'login.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const List<_CategoryItem> _categories = [
    _CategoryItem(
      label: 'Masculino',
      icon: Icons.man_outlined,
      color: Color(0xFF1A3A5C),
      imageUrl:
          'https://images.pexels.com/photos/1043474/pexels-photo-1043474.jpeg?auto=compress&cs=tinysrgb&w=600',
    ),
    _CategoryItem(
      label: 'Femenino',
      icon: Icons.woman_outlined,
      color: Color(0xFF5C1A3A),
      imageUrl:
          'https://images.pexels.com/photos/1036623/pexels-photo-1036623.jpeg?auto=compress&cs=tinysrgb&w=600',
    ),
    _CategoryItem(
      label: 'Infantiles',
      icon: Icons.child_care_outlined,
      color: Color(0xFF1A5C3A),
      imageUrl:
          'https://images.pexels.com/photos/35537/child-children-girl-happy.jpg?auto=compress&cs=tinysrgb&w=600',
    ),
  ];

  void _navigateTo(BuildContext context, int index) {
    Widget screen;
    switch (index) {
      case 0:
        screen = const MasculinoScreen();
        break;
      case 1:
        screen = const FemeninoScreen();
        break;
      case 2:
        screen = const InfantilesScreen();
        break;
      default:
        return;
    }
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A2E),
        elevation: 0,
        title: const Text(
          'Tienda',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.logout_outlined, color: Colors.white),
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (_) => false,
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Banner(),
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 28, 20, 16),
                child: Text(
                  'Categorías',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A2E),
                    letterSpacing: -0.3,
                  ),
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _categories.length,
                itemBuilder: (context, i) {
                  final cat = _categories[i];
                  return _CategoryCard(
                    item: cat,
                    onTap: () => _navigateTo(context, i),
                  );
                },
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _Banner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      height: 160,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            bottom: -20,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),
          Positioned(
            right: 40,
            top: -30,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.04),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Nueva colección',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1.2,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Temporada\nPrimavera 2025',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                    letterSpacing: -0.3,
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  'Descubre las últimas tendencias',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final _CategoryItem item;
  final VoidCallback onTap;

  const _CategoryCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        height: 120,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                item.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(color: item.color),
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      item.color.withOpacity(0.85),
                      item.color.withOpacity(0.3),
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(item.icon, color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.label,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Ver colección',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    const Icon(Icons.arrow_forward_ios,
                        color: Colors.white70, size: 16),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryItem {
  final String label;
  final IconData icon;
  final Color color;
  final String imageUrl;

  const _CategoryItem({
    required this.label,
    required this.icon,
    required this.color,
    required this.imageUrl,
  });
}
