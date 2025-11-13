import 'package:flutter/material.dart';

/// Widget AspectRatio personnalisé - Équivalent de Radix UI AspectRatio
///
/// Flutter a déjà un widget AspectRatio natif, mais cette version
/// ajoute des ratios prédéfinis et des helpers pour faciliter l'utilisation
class CustomAspectRatio extends StatelessWidget {
  final double? ratio;
  final AspectRatioPreset? preset;
  final Widget child;

  const CustomAspectRatio({
    Key? key,
    this.ratio,
    this.preset,
    required this.child,
  }) : assert(
         ratio != null || preset != null,
         'Either ratio or preset must be provided',
       ),
       super(key: key);

  /// Constructeur avec ratio personnalisé
  const CustomAspectRatio.ratio({
    Key? key,
    required double ratio,
    required Widget child,
  }) : this(key: key, ratio: ratio, child: child);

  /// Constructeur avec preset
  const CustomAspectRatio.preset({
    Key? key,
    required AspectRatioPreset preset,
    required Widget child,
  }) : this(key: key, preset: preset, child: child);

  // Presets courants
  const CustomAspectRatio.square({Key? key, required Widget child})
    : this(key: key, preset: AspectRatioPreset.square, child: child);

  const CustomAspectRatio.video({Key? key, required Widget child})
    : this(key: key, preset: AspectRatioPreset.video, child: child);

  const CustomAspectRatio.portrait({Key? key, required Widget child})
    : this(key: key, preset: AspectRatioPreset.portrait, child: child);

  const CustomAspectRatio.landscape({Key? key, required Widget child})
    : this(key: key, preset: AspectRatioPreset.landscape, child: child);

  const CustomAspectRatio.ultrawide({Key? key, required Widget child})
    : this(key: key, preset: AspectRatioPreset.ultrawide, child: child);

  const CustomAspectRatio.instagram({Key? key, required Widget child})
    : this(key: key, preset: AspectRatioPreset.instagram, child: child);

  const CustomAspectRatio.story({Key? key, required Widget child})
    : this(key: key, preset: AspectRatioPreset.story, child: child);

  @override
  Widget build(BuildContext context) {
    final aspectRatio = ratio ?? preset!.value;

    return AspectRatio(aspectRatio: aspectRatio, child: child);
  }
}

/// Presets de ratios d'aspect courants
enum AspectRatioPreset {
  /// 1:1 - Carré
  square(1 / 1),

  /// 16:9 - Vidéo standard, TV HD
  video(16 / 9),

  /// 4:3 - TV classique
  classic(4 / 3),

  /// 3:2 - Photo classique
  photo(3 / 2),

  /// 2:3 - Portrait
  portrait(2 / 3),

  /// 16:10 - Écran large
  landscape(16 / 10),

  /// 21:9 - Cinéma ultrawide
  ultrawide(21 / 9),

  /// 4:5 - Instagram portrait
  instagram(4 / 5),

  /// 9:16 - Instagram/TikTok story
  story(9 / 16),

  /// 1.91:1 - Facebook cover
  facebookCover(1.91 / 1),

  /// 3:1 - Twitter header
  twitterHeader(3 / 1),

  /// 2.39:1 - Cinéma widescreen
  cinema(2.39 / 1),

  /// 1.414:1 - A4 papier
  a4(1.414 / 1),

  /// φ (phi) - Golden ratio
  golden(1.618 / 1);

  final double value;
  const AspectRatioPreset(this.value);
}

/// Widget helper pour créer une grille avec aspect ratio
class AspectRatioGrid extends StatelessWidget {
  final List<Widget> children;
  final int crossAxisCount;
  final AspectRatioPreset preset;
  final double mainAxisSpacing;
  final double crossAxisSpacing;
  final EdgeInsetsGeometry? padding;

  const AspectRatioGrid({
    Key? key,
    required this.children,
    required this.crossAxisCount,
    this.preset = AspectRatioPreset.square,
    this.mainAxisSpacing = 8.0,
    this.crossAxisSpacing = 8.0,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: padding,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: preset.value,
        mainAxisSpacing: mainAxisSpacing,
        crossAxisSpacing: crossAxisSpacing,
      ),
      itemCount: children.length,
      itemBuilder: (context, index) => children[index],
    );
  }
}

/// Widget pour une image avec aspect ratio
class AspectRatioImage extends StatelessWidget {
  final String imageUrl;
  final AspectRatioPreset preset;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final BorderRadius? borderRadius;

  const AspectRatioImage({
    Key? key,
    required this.imageUrl,
    this.preset = AspectRatioPreset.video,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.borderRadius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomAspectRatio.preset(
      preset: preset,
      child: ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.zero,
        child: Image.network(
          imageUrl,
          fit: fit,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return placeholder ??
                Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                        : null,
                  ),
                );
          },
          errorBuilder: (context, error, stackTrace) {
            return errorWidget ??
                Container(
                  color: Colors.grey[300],
                  child: const Icon(Icons.broken_image, size: 50),
                );
          },
        ),
      ),
    );
  }
}

/// Exemple d'utilisation complète
class AspectRatioExample extends StatelessWidget {
  const AspectRatioExample({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Aspect Ratio Examples')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Ratios prédéfinis',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Carré (1:1)
          _buildExample(
            'Square (1:1)',
            CustomAspectRatio.square(
              child: Container(
                color: Colors.blue,
                child: const Center(
                  child: Text(
                    '1:1',
                    style: TextStyle(color: Colors.white, fontSize: 24),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Vidéo (16:9)
          _buildExample(
            'Video (16:9)',
            CustomAspectRatio.video(
              child: Container(
                color: Colors.green,
                child: const Center(
                  child: Text(
                    '16:9',
                    style: TextStyle(color: Colors.white, fontSize: 24),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Portrait (2:3)
          _buildExample(
            'Portrait (2:3)',
            CustomAspectRatio.portrait(
              child: Container(
                color: Colors.purple,
                child: const Center(
                  child: Text(
                    '2:3',
                    style: TextStyle(color: Colors.white, fontSize: 24),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Instagram (4:5)
          _buildExample(
            'Instagram (4:5)',
            CustomAspectRatio.instagram(
              child: Container(
                color: Colors.pink,
                child: const Center(
                  child: Text(
                    '4:5',
                    style: TextStyle(color: Colors.white, fontSize: 24),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Story (9:16)
          _buildExample(
            'Story (9:16)',
            CustomAspectRatio.story(
              child: Container(
                color: Colors.orange,
                child: const Center(
                  child: Text(
                    '9:16',
                    style: TextStyle(color: Colors.white, fontSize: 24),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Golden Ratio
          _buildExample(
            'Golden Ratio (φ)',
            CustomAspectRatio.preset(
              preset: AspectRatioPreset.golden,
              child: Container(
                color: Colors.amber,
                child: const Center(
                  child: Text(
                    '1.618:1',
                    style: TextStyle(color: Colors.white, fontSize: 24),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),

          const Text(
            'Images avec aspect ratio',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Image 16:9
          AspectRatioImage(
            imageUrl:
                'https://images.unsplash.com/photo-1506905925346-21bda4d32df4',
            preset: AspectRatioPreset.video,
            borderRadius: BorderRadius.circular(12),
          ),
          const SizedBox(height: 16),

          // Image carrée
          AspectRatioImage(
            imageUrl:
                'https://images.unsplash.com/photo-1511688878353-3a2f5be94cd7',
            preset: AspectRatioPreset.square,
            borderRadius: BorderRadius.circular(12),
          ),
          const SizedBox(height: 32),

          const Text(
            'Grille avec aspect ratio',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Grille d'images
          SizedBox(
            height: 400,
            child: AspectRatioGrid(
              crossAxisCount: 2,
              preset: AspectRatioPreset.square,
              children: List.generate(
                6,
                (index) => Container(
                  decoration: BoxDecoration(
                    color: Colors.primaries[index % Colors.primaries.length],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      'Item ${index + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),

          const Text(
            'Ratio personnalisé',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Ratio personnalisé (3:1)
          _buildExample(
            'Custom (3:1)',
            CustomAspectRatio.ratio(
              ratio: 3 / 1,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade400, Colors.purple.shade400],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Text(
                    '3:1 Custom',
                    style: TextStyle(color: Colors.white, fontSize: 24),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Tableau de tous les presets
          const Text(
            'Tous les presets disponibles',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          ...AspectRatioPreset.values.map((preset) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      preset.name,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(
                      preset.value.toStringAsFixed(2),
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: CustomAspectRatio.preset(
                      preset: preset,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.blue.shade100,
                          border: Border.all(color: Colors.blue),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildExample(String title, Widget child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}
