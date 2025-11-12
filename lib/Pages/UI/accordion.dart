import 'package:flutter/material.dart';
import 'package:mobile_app_project/Pages/UI/AppColors.dart';

class Accordion extends StatefulWidget {
  final List<AccordionItem> items;
  final bool allowMultiple;

  const Accordion({Key? key, required this.items, this.allowMultiple = false})
    : super(key: key);

  @override
  State<Accordion> createState() => _AccordionState();
}

class _AccordionState extends State<Accordion> {
  final Set<int> _expandedIndexes = {};

  void _toggleItem(int index) {
    setState(() {
      if (_expandedIndexes.contains(index)) {
        _expandedIndexes.remove(index);
      } else {
        if (!widget.allowMultiple) {
          _expandedIndexes.clear();
        }
        _expandedIndexes.add(index);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryOrange.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryOrange.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: List.generate(widget.items.length, (index) {
          final item = widget.items[index];
          final isExpanded = _expandedIndexes.contains(index);
          final isLast = index == widget.items.length - 1;

          return Column(
            children: [
              InkWell(
                onTap: () => _toggleItem(index),
                borderRadius: BorderRadius.vertical(
                  top: index == 0 ? const Radius.circular(16) : Radius.zero,
                  bottom: isLast && !isExpanded
                      ? const Radius.circular(16)
                      : Radius.zero,
                ),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isExpanded
                        ? AppColors.primaryOrange.withOpacity(0.05)
                        : Colors.transparent,
                    borderRadius: BorderRadius.vertical(
                      top: index == 0 ? const Radius.circular(16) : Radius.zero,
                      bottom: isLast && !isExpanded
                          ? const Radius.circular(16)
                          : Radius.zero,
                    ),
                  ),
                  child: Row(
                    children: [
                      if (item.icon != null) ...[
                        Icon(
                          item.icon,
                          color: AppColors.primaryOrange,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                      ],
                      Expanded(
                        child: Text(
                          item.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      Icon(
                        isExpanded
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        color: AppColors.primaryOrange,
                      ),
                    ],
                  ),
                ),
              ),
              AnimatedCrossFade(
                firstChild: const SizedBox.shrink(),
                secondChild: Container(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: item.content,
                ),
                crossFadeState: isExpanded
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 200),
              ),
              if (!isLast)
                Divider(
                  height: 1,
                  color: AppColors.primaryOrange.withOpacity(0.1),
                ),
            ],
          );
        }),
      ),
    );
  }
}

class AccordionItem {
  final String title;
  final Widget content;
  final IconData? icon;

  AccordionItem({required this.title, required this.content, this.icon});
}
