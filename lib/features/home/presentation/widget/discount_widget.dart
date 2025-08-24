import 'package:flutter/material.dart';
class PromoBannerCard extends StatelessWidget {
  const PromoBannerCard({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFE9F7EF), // soft green
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: const Color(0xFF16A34A), // green
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.verified, size: 18, color: Colors.white),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 2,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF065F46), // deep green
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280), // gray-500
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right, color: Color(0xFF6B7280)),
        ],
      ),
    );
  }
}



class ServicesPanel extends StatelessWidget {
  const ServicesPanel({super.key,
    required this.title,
    required this.items,
  });

  final String title;
  final List<ServiceItem> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)), // gray-200
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000), // subtle
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // header
          Row(
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              const Icon(Icons.chevron_right, color: Color(0xFF9CA3AF)),
            ],
          ),
          const SizedBox(height: 10),

          // 4 tiles (fixed row; wraps on small screens)
          LayoutBuilder(
            builder: (context, c) {
              final double tileWidth = (c.maxWidth - 18) / 4; // 3 gaps × 6 = 18
              return Wrap(
                spacing: 6,
                runSpacing: 6,
                children: items
                    .map((e) => ServiceTile(item: e, width: tileWidth))
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class ServiceItem {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  const ServiceItem({required this.icon, required this.label, this.onTap});
}

class ServiceTile extends StatelessWidget {
  const ServiceTile({required this.item, required this.width});
  final ServiceItem item;
  final double width;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: item.onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: width,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB), // gray-50
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(item.icon, size: 22, color: const Color(0xFF374151)),
            const SizedBox(height: 8),
            Text(
              item.label,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}