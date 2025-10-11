import 'package:flutter/material.dart';

class Menubar extends StatelessWidget {
  final List<Widget> children;
  const Menubar({Key? key, required this.children}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      height: 36,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.background,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 2)],
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: children),
    );
  }
}

class MenubarItem extends StatelessWidget {
  final Widget child;
  final bool destructive;
  final VoidCallback? onPressed;

  const MenubarItem({
    Key? key,
    required this.child,
    this.destructive = false,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textColor = destructive ? Colors.red : Colors.black87;

    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(4),
      hoverColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: DefaultTextStyle(
          style: TextStyle(color: textColor, fontSize: 14),
          child: child,
        ),
      ),
    );
  }
}

class MenubarSub extends StatelessWidget {
  final Widget trigger;
  final List<Widget> children;

  const MenubarSub({Key? key, required this.trigger, required this.children})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<int>(
      offset: const Offset(0, 0),
      child: trigger,
      itemBuilder: (context) => children
          .asMap()
          .entries
          .map(
            (entry) => PopupMenuItem<int>(value: entry.key, child: entry.value),
          )
          .toList(),
    );
  }
}

class MenubarCheckboxItem extends StatelessWidget {
  final bool checked;
  final Widget child;
  final ValueChanged<bool?>? onChanged;

  const MenubarCheckboxItem({
    Key? key,
    required this.checked,
    required this.child,
    this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged?.call(!checked),
      child: Row(
        children: [
          Checkbox(value: checked, onChanged: onChanged),
          child,
        ],
      ),
    );
  }
}

class MenubarRadioItem<T> extends StatelessWidget {
  final T value;
  final T groupValue;
  final Widget child;
  final ValueChanged<T?>? onChanged;

  const MenubarRadioItem({
    Key? key,
    required this.value,
    required this.groupValue,
    required this.child,
    this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged?.call(value),
      child: Row(
        children: [
          Radio<T>(value: value, groupValue: groupValue, onChanged: onChanged),
          child,
        ],
      ),
    );
  }
}

class MenubarSeparator extends StatelessWidget {
  const MenubarSeparator({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 1,
      child: Divider(height: 1, thickness: 1, color: Colors.grey),
    );
  }
}

class MenubarLabel extends StatelessWidget {
  final String text;
  final bool inset;

  const MenubarLabel({Key? key, required this.text, this.inset = false})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: inset ? 16 : 0),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
      ),
    );
  }
}

class MenubarShortcut extends StatelessWidget {
  final String shortcut;

  const MenubarShortcut({Key? key, required this.shortcut}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      shortcut,
      style: const TextStyle(
        fontSize: 12,
        color: Colors.grey,
        letterSpacing: 1.5,
      ),
    );
  }
}
