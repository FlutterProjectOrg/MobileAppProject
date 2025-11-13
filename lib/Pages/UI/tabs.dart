import 'package:flutter/material.dart';

class CustomTabs extends StatelessWidget {
  final List<String> tabs;
  final List<Widget> tabContents;
  final double height;

  const CustomTabs({
    Key? key,
    required this.tabs,
    required this.tabContents,
    this.height = 200,
  }) : assert(tabs.length == tabContents.length),
       super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: tabs.length,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[200], // équivalent bg-muted
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              labelColor: Theme.of(context).colorScheme.onSurface,
              unselectedLabelColor: Colors.grey[600],
              indicator: BoxDecoration(
                color: Colors.white, // équivalent data-[state=active]:bg-card
                borderRadius: BorderRadius.circular(12),
              ),
              tabs: tabs.map((tab) => Tab(text: tab)).toList(),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: height,
            child: TabBarView(children: tabContents),
          ),
        ],
      ),
    );
  }
}
