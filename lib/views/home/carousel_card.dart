import 'package:flutter/material.dart';

class CarouselCard extends StatelessWidget {
  final Future<String>? imageUrl;
  final String title;
  final String? heroTag; // Unique base for Hero tag
  final bool enableHero;

  const CarouselCard({
    Key? key,
    required this.imageUrl,
    required this.title,
    this.heroTag,
    this.enableHero = true,
  }) : super(key: key);

  bool _isValidHttpUrl(String? value) {
    if (value == null || value.trim().isEmpty) return false;
    final uri = Uri.tryParse(value.trim());
    return uri != null &&
        (uri.scheme == 'http' || uri.scheme == 'https') &&
        (uri.host.isNotEmpty);
  }

  Widget _fallbackAsset() {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('lib/resources/assets/images/stock-image.png'),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20), // overall rounded corners
      child: Container(
        width: double.infinity, // you can adjust this for your carousel size
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Image

            AspectRatio(
              aspectRatio: 16 / 9,
              child: imageUrl != null
                  ? FutureBuilder<String>(
                      future: imageUrl,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Container(
                            color: Colors.grey[200], // Placeholder color
                            child: const Center(),
                          );
                        }
                        if (snapshot.hasError ||
                            !_isValidHttpUrl(snapshot.data)) {
                          return _fallbackAsset();
                        }

                        final imageWidget = Image.network(
                          snapshot.data!.trim(),
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              color: Colors.grey[200], // Placeholder color
                              child: const Center(),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return _fallbackAsset();
                          },
                          fit: BoxFit.cover,
                        );
                        if (!enableHero) return imageWidget;
                        return Hero(
                          tag: "${(heroTag ?? title)}_image",
                          child: imageWidget,
                        );
                      })
                  : _fallbackAsset(), // Placeholder color),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
