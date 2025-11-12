import 'package:flutter/material.dart';
import 'package:mobile_app_project/Pages/UI/AppColors.dart';

class CustomTable extends StatelessWidget {
  final List<TableColumn> columns;
  final List<Map<String, dynamic>> data;
  final bool showHeader;
  final bool striped;

  const CustomTable({
    Key? key,
    required this.columns,
    required this.data,
    this.showHeader = true,
    this.striped = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primaryOrange.withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryOrange.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingRowColor: showHeader
                ? MaterialStateProperty.all(
                    AppColors.primaryOrange.withOpacity(0.1),
                  )
                : null,
            dataRowColor: MaterialStateProperty.resolveWith((states) {
              if (striped && states.contains(MaterialState.selected)) {
                return AppColors.background;
              }
              return null;
            }),
            columns: columns.map((col) {
              return DataColumn(
                label: Row(
                  children: [
                    if (col.icon != null) ...[
                      Icon(
                        col.icon,
                        size: 16,
                        color: AppColors.primaryOrange,
                      ),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      col.label,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            rows: data.asMap().entries.map((entry) {
              final index = entry.key;
              final row = entry.value;
              
              return DataRow(
                selected: striped && index % 2 == 1,
                cells: columns.map((col) {
                  final value = row[col.key];
                  return DataCell(
                    col.builder != null
                        ? col.builder!(value, row)
                        : Text(
                            value?.toString() ?? '',
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.textPrimary,
                            ),
                          ),
                  );
                }).toList(),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class TableColumn {
  final String key;
  final String label;
  final IconData? icon;
  final Widget Function(dynamic value, Map<String, dynamic> row)? builder;

  TableColumn({
    required this.key,
    required this.label,
    this.icon,
    this.builder,
  });
}
