import 'package:flutter/material.dart';

class RideOptionCard extends StatelessWidget {
  const RideOptionCard({
    super.key,
    this.title = '',
    this.timeText = '',
    this.etaText = '',
    this.priceText = '',
    this.pillText = 'Shortest',
    this.brandColor = const Color(0xFF28C16D),
    this.width = 360,
    this.image,
    this.isShortest = false,
    this.onTap
  });

  final String title;
  final String timeText;
  final String etaText;
  final String priceText;
  final String pillText;
  final Color brandColor;
  final double width;
  final Widget? image;
  final bool isShortest;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: .6) ??
        Colors.grey.shade600;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        InkWell(
          onTap: onTap,
          child: Container(
            width: width,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              border: isShortest ? Border.all(color: brandColor, width: 1):Border.all(color: Colors.grey.withValues(alpha: 0.3), width: 1),
              borderRadius: BorderRadius.circular(14),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x08000000),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                )
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Car image / placeholder
                SizedBox(
                  width: 45,
                  height: 44,
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: image ??
                        Icon(Icons.directions_car_filled_rounded,
                            size: 44, color: Colors.grey.shade400),
                  ),
                ),
                const SizedBox(width: 14),
                // Title + meta
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                          letterSpacing: .2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(timeText,
                              style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w500,
                                  color: muted)),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Container(
                              width: 4,
                              height: 4,
                              decoration: BoxDecoration(
                                color: muted,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                          Text(etaText,
                              style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w500,
                                  color: muted)),
                        ],
                      ),
                    ],
                  ),
                ),
                // Price
                Text(
                  priceText,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 22,
                    letterSpacing: .2,
                  ),
                ),
              ],
            ),
          ),
        ),
        if(isShortest)
        Positioned(
          right: 0,
          top: 0,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            decoration: BoxDecoration(
              color: brandColor,
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(14),
                bottomLeft: Radius.circular(14),
              ),
              boxShadow: [
                BoxShadow(
                  color: brandColor.withValues(alpha: .25),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              pillText,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
                fontSize: 12,
                height: 1,
              ),
            ),
          ),
        ),
      ],
    );
  }
}