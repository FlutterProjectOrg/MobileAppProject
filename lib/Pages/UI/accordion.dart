import 'package:flutter/material.dart';

/// Widget Accordion pour Flutter - Équivalent de Radix UI Accordion
class Accordion extends StatelessWidget {
  final List<AccordionItem> items;
  final bool allowMultiple;
  final List<int>? initialExpandedIndexes;

  const Accordion({
    Key? key,
    required this.items,
    this.allowMultiple = false,
    this.initialExpandedIndexes,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (allowMultiple) {
      return _MultiAccordion(
        items: items,
        initialExpandedIndexes: initialExpandedIndexes ?? [],
      );
    }
    return _SingleAccordion(
      items: items,
      initialExpandedIndex: initialExpandedIndexes?.firstOrNull,
    );
  }
}

/// Accordion qui permet d'ouvrir plusieurs items en même temps
class _MultiAccordion extends StatefulWidget {
  final List<AccordionItem> items;
  final List<int> initialExpandedIndexes;

  const _MultiAccordion({
    required this.items,
    required this.initialExpandedIndexes,
  });

  @override
  State<_MultiAccordion> createState() => _MultiAccordionState();
}

class _MultiAccordionState extends State<_MultiAccordion> {
  late Set<int> _expandedIndexes;

  @override
  void initState() {
    super.initState();
    _expandedIndexes = Set.from(widget.initialExpandedIndexes);
  }

  void _toggleItem(int index) {
    setState(() {
      if (_expandedIndexes.contains(index)) {
        _expandedIndexes.remove(index);
      } else {
        _expandedIndexes.add(index);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(widget.items.length, (index) {
        final item = widget.items[index];
        final isLast = index == widget.items.length - 1;
        final isExpanded = _expandedIndexes.contains(index);

        return _AccordionItemWidget(
          item: item,
          isExpanded: isExpanded,
          isLast: isLast,
          onToggle: () => _toggleItem(index),
        );
      }),
    );
  }
}

/// Accordion qui permet d'ouvrir un seul item à la fois
class _SingleAccordion extends StatefulWidget {
  final List<AccordionItem> items;
  final int? initialExpandedIndex;

  const _SingleAccordion({required this.items, this.initialExpandedIndex});

  @override
  State<_SingleAccordion> createState() => _SingleAccordionState();
}

class _SingleAccordionState extends State<_SingleAccordion> {
  int? _expandedIndex;

  @override
  void initState() {
    super.initState();
    _expandedIndex = widget.initialExpandedIndex;
  }

  void _toggleItem(int index) {
    setState(() {
      _expandedIndex = _expandedIndex == index ? null : index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(widget.items.length, (index) {
        final item = widget.items[index];
        final isLast = index == widget.items.length - 1;
        final isExpanded = _expandedIndex == index;

        return _AccordionItemWidget(
          item: item,
          isExpanded: isExpanded,
          isLast: isLast,
          onToggle: () => _toggleItem(index),
        );
      }),
    );
  }
}

/// Widget individuel pour chaque item de l'accordion
class _AccordionItemWidget extends StatelessWidget {
  final AccordionItem item;
  final bool isExpanded;
  final bool isLast;
  final VoidCallback onToggle;

  const _AccordionItemWidget({
    required this.item,
    required this.isExpanded,
    required this.isLast,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final borderColor = theme.dividerColor;

    return Container(
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(bottom: BorderSide(color: borderColor, width: 1)),
      ),
      child: Column(
        children: [
          // Trigger (Header)
          InkWell(
            onTap: item.enabled ? onToggle : null,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                children: [
                  // Title
                  Expanded(
                    child: item.titleBuilder != null
                        ? item.titleBuilder!(context, isExpanded)
                        : Text(
                            item.title ?? '',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                  const SizedBox(width: 16),
                  // Icon
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      color: theme.textTheme.bodySmall?.color,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Content
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            child: isExpanded
                ? Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: item.contentBuilder != null
                        ? item.contentBuilder!(context)
                        : Text(
                            item.content ?? '',
                            style: theme.textTheme.bodyMedium,
                          ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

/// Classe de données pour un item d'accordion
class AccordionItem {
  final String? title;
  final String? content;
  final Widget Function(BuildContext, bool isExpanded)? titleBuilder;
  final Widget Function(BuildContext)? contentBuilder;
  final bool enabled;

  const AccordionItem({
    this.title,
    this.content,
    this.titleBuilder,
    this.contentBuilder,
    this.enabled = true,
  }) : assert(
         title != null || titleBuilder != null,
         'Either title or titleBuilder must be provided',
       ),
       assert(
         content != null || contentBuilder != null,
         'Either content or contentBuilder must be provided',
       );
}

/// Exemple d'utilisation avec style personnalisé
class StyledAccordionItem extends StatelessWidget {
  final String title;
  final String content;
  final IconData? icon;
  final Color? accentColor;

  const StyledAccordionItem({
    Key? key,
    required this.title,
    required this.content,
    this.icon,
    this.accentColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Accordion(
      items: [
        AccordionItem(
          titleBuilder: (context, isExpanded) {
            return Row(
              children: [
                if (icon != null) ...[
                  Icon(
                    icon,
                    color: accentColor ?? Theme.of(context).primaryColor,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isExpanded
                          ? (accentColor ?? Theme.of(context).primaryColor)
                          : null,
                    ),
                  ),
                ),
              ],
            );
          },
          contentBuilder: (context) {
            return Text(
              content,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).textTheme.bodyMedium?.color,
                height: 1.5,
              ),
            );
          },
        ),
      ],
    );
  }
}

/// Exemple d'utilisation
class AccordionExample extends StatelessWidget {
  const AccordionExample({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Accordion Example')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Single Selection',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Accordion(
              allowMultiple: false,
              items: [
                const AccordionItem(
                  title: 'Qu\'est-ce que Flutter?',
                  content:
                      'Flutter est un framework open-source développé par Google pour créer des applications mobiles, web et desktop à partir d\'une seule base de code.',
                ),
                const AccordionItem(
                  title: 'Pourquoi utiliser Flutter?',
                  content:
                      'Flutter offre un développement rapide, des performances natives, et un design élégant avec Material Design et Cupertino widgets.',
                ),
                AccordionItem(
                  titleBuilder: (context, isExpanded) {
                    return Row(
                      children: [
                        Icon(Icons.code, color: Theme.of(context).primaryColor),
                        const SizedBox(width: 8),
                        const Text('Dart Language'),
                      ],
                    );
                  },
                  contentBuilder: (context) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Dart est le langage de programmation utilisé par Flutter.',
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () {},
                          child: const Text('En savoir plus'),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 32),
            const Text(
              'Multiple Selection',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Accordion(
              allowMultiple: true,
              initialExpandedIndexes: [0],
              items: const [
                AccordionItem(
                  title: 'Installation',
                  content:
                      'Téléchargez Flutter SDK, configurez votre environnement, et installez les outils nécessaires.',
                ),
                AccordionItem(
                  title: 'Configuration',
                  content:
                      'Configurez votre IDE (VS Code ou Android Studio) avec les extensions Flutter et Dart.',
                ),
                AccordionItem(
                  title: 'Premier projet',
                  content:
                      'Créez votre première application avec flutter create et lancez-la avec flutter run.',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
