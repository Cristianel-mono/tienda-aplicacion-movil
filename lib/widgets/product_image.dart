import 'package:flutter/material.dart';

class ProductImage extends StatelessWidget {
  final String? imageUrl;
  final String name;
  final double? height;
  final double iconSize;
  final BoxFit fit;

  const ProductImage({
    super.key,
    required this.name,
    this.imageUrl,
    this.height,
    this.iconSize = 42,
    this.fit = BoxFit.cover,
  });

  String? get _assetPath {
    final value = name.toLowerCase();
    if (value.contains('audí') || value.contains('audi') || value.contains('auric')) {
      return 'assets/products/audifonos.png';
    }
    if (value.contains('mouse')) return 'assets/products/mouse.png';
    if (value.contains('camis')) return 'assets/products/camiseta.png';
    if (value.contains('lámp') || value.contains('lamp')) return 'assets/products/lampara.png';
    if (value.contains('bal')) return 'assets/products/balon.png';
    return null;
  }

  bool get _hasRealPhoto {
    final url = imageUrl;
    if (url == null || url.trim().isEmpty) return false;
    return !url.contains('picsum.photos');
  }

  IconData _iconFor(String productName) {
    final value = productName.toLowerCase();
    if (value.contains('audí') || value.contains('audi') || value.contains('auric')) {
      return Icons.headphones_rounded;
    }
    if (value.contains('mouse')) return Icons.mouse_rounded;
    if (value.contains('camis') || value.contains('chaquet') || value.contains('jean')) {
      return Icons.checkroom_rounded;
    }
    if (value.contains('lámp') || value.contains('lamp')) return Icons.light_rounded;
    if (value.contains('sában') || value.contains('saban')) return Icons.bed_rounded;
    if (value.contains('bal')) return Icons.sports_soccer_rounded;
    if (value.contains('mancuern') || value.contains('reloj') || value.contains('watch')) {
      return Icons.fitness_center_rounded;
    }
    if (value.contains('tablet')) return Icons.tablet_mac_rounded;
    return Icons.shopping_bag_outlined;
  }

  @override
  Widget build(BuildContext context) {
    final assetPath = _assetPath;
    if (assetPath != null) {
      return Image.asset(
        assetPath,
        height: height,
        width: double.infinity,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => _placeholder(),
      );
    }

    if (!_hasRealPhoto) {
      return _placeholder();
    }

    return Image.network(
      imageUrl!,
      height: height,
      width: double.infinity,
      fit: fit,
      errorBuilder: (context, error, stackTrace) => _placeholder(),
    );
  }

  Widget _placeholder() {
    return Container(
      height: height,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFF8EBE3), Color(0xFFEBD5C6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Icon(
        _iconFor(name),
        size: iconSize,
        color: const Color(0xFF8C4A2F),
      ),
    );
  }
}
