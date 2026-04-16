import 'package:flutter/material.dart';

class CategoriasHorizontal extends StatelessWidget {
  const CategoriasHorizontal({super.key});

  static const List<_SubCategory> _items = [
    _SubCategory(
      label: 'Tenis',
      imageUrl:
          'https://images.pexels.com/photos/2529148/pexels-photo-2529148.jpeg?auto=compress&cs=tinysrgb&w=300',
    ),
    _SubCategory(
      label: 'Botas',
      imageUrl:
          'https://images.pexels.com/photos/267301/pexels-photo-267301.jpeg?auto=compress&cs=tinysrgb&w=300',
    ),
    _SubCategory(
      label: 'Camisetas',
      imageUrl:
          'https://images.pexels.com/photos/996329/pexels-photo-996329.jpeg?auto=compress&cs=tinysrgb&w=300',
    ),
    _SubCategory(
      label: 'Futbol Sports',
      imageUrl:
          'https://images.pexels.com/photos/46798/the-ball-stadion-football-the-pitch-46798.jpeg?auto=compress&cs=tinysrgb&w=300',
    ),
    _SubCategory(
      label: 'Accesorios',
      imageUrl:
          'https://images.pexels.com/photos/1152077/pexels-photo-1152077.jpeg?auto=compress&cs=tinysrgb&w=300',
    ),
    _SubCategory(
      label: 'Deportivo',
      imageUrl:
          'https://images.pexels.com/photos/2827400/pexels-photo-2827400.jpeg?auto=compress&cs=tinysrgb&w=300',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 108,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
        itemCount: _items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 18),
        itemBuilder: (context, i) => _SubCategoryItem(item: _items[i]),
      ),
    );
  }
}

class _SubCategoryItem extends StatelessWidget {
  final _SubCategory item;
  const _SubCategoryItem({required this.item});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: SizedBox(
        width: 72,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFF0EEF6),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipOval(
                child: Image.network(
                  item.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: const Color(0xFFE8E8E8),
                    child: const Icon(
                      Icons.image_outlined,
                      color: Color(0xFFBDBDBD),
                      size: 28,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              item.label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1A1A2E),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SubCategory {
  final String label;
  final String imageUrl;
  const _SubCategory({required this.label, required this.imageUrl});
}
