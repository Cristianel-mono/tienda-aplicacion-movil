import 'package:flutter/material.dart';
import '../core/app_theme.dart';
import '../models/product.dart';
import 'product_image.dart';

class ProductCard extends StatefulWidget {
  final Product product;
  final VoidCallback onTap;
  final VoidCallback? onAdd;

  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
    this.onAdd,
  });

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  bool _hover = false;
  bool _favorite = false;

  bool get _featured {
    final name = widget.product.name.toLowerCase();
    return name.contains('audí') || name.contains('audi') || name.contains('auric');
  }

  @override
  Widget build(BuildContext context) {
    final highlighted = _featured || _hover;

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: highlighted ? AppTheme.accent : AppTheme.line,
            width: highlighted ? 1.6 : 1,
          ),
          boxShadow: highlighted
              ? [
                  BoxShadow(
                    color: AppTheme.accent.withValues(alpha: 0.28),
                    blurRadius: 18,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(17),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onTap,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        ColoredBox(
                          color: const Color(0xFFF4F5F7),
                          child: ProductImage(
                            name: widget.product.name,
                            imageUrl: widget.product.imageUrl,
                            fit: BoxFit.contain,
                          ),
                        ),
                        Positioned(
                          top: 10,
                          right: 10,
                          child: _FavoriteButton(
                            active: _favorite,
                            onPressed: () => setState(() => _favorite = !_favorite),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.product.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: AppTheme.ink,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '\$${widget.product.price.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  color: AppTheme.price,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: widget.onAdd,
                          style: TextButton.styleFrom(
                            foregroundColor: AppTheme.ink,
                            visualDensity: VisualDensity.compact,
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('Añadir', style: TextStyle(fontWeight: FontWeight.w600)),
                              SizedBox(width: 4),
                              Icon(Icons.shopping_cart_outlined, size: 16),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FavoriteButton extends StatelessWidget {
  final bool active;
  final VoidCallback onPressed;

  const _FavoriteButton({required this.active, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: active ? Colors.white : const Color(0xCC1B2333),
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onPressed,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: active ? 10 : 8, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                active ? Icons.favorite : Icons.favorite_border,
                size: 16,
                color: active ? const Color(0xFFE11D48) : Colors.white,
              ),
              if (active) ...[
                const SizedBox(width: 4),
                const Text(
                  'Favorito',
                  style: TextStyle(
                    color: Color(0xFF121826),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
