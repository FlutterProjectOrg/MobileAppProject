import 'package:flutter/material.dart';

class CommandDialog extends StatefulWidget {
  final String title;
  final String description;
  final List<CommandItemData> items;

  const CommandDialog({
    Key? key,
    this.title = "Command Palette",
    this.description = "Search for a command to run...",
    required this.items,
  }) : super(key: key);

  @override
  _CommandDialogState createState() => _CommandDialogState();
}

class _CommandDialogState extends State<CommandDialog> {
  String _search = "";

  @override
  Widget build(BuildContext context) {
    final filteredItems = widget.items
        .where(
          (item) => item.label.toLowerCase().contains(_search.toLowerCase()),
        )
        .toList();

    return Dialog(
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title and Description
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.description,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 12),
              ],
            ),

            // Input
            TextField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: "Type a command...",
                border: OutlineInputBorder(),
                isDense: true,
                contentPadding: EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 8,
                ),
              ),
              onChanged: (value) => setState(() {
                _search = value;
              }),
            ),

            const SizedBox(height: 12),

            // List of commands
            Expanded(
              child: filteredItems.isEmpty
                  ? const Center(child: Text("No commands found"))
                  : ListView.builder(
                      itemCount: filteredItems.length,
                      itemBuilder: (context, index) {
                        final item = filteredItems[index];
                        return ListTile(
                          leading: item.icon != null ? Icon(item.icon) : null,
                          title: Text(item.label),
                          onTap: () {
                            Navigator.of(context).pop();
                            item.onSelected();
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// Data model for a command item
class CommandItemData {
  final String label;
  final IconData? icon;
  final VoidCallback onSelected;

  CommandItemData({required this.label, this.icon, required this.onSelected});
}
