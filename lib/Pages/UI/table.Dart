import 'package:flutter/material.dart';

class CustomTable extends StatelessWidget {
  final List<String> headers;
  final List<List<String>> rows;
  final String? caption;

  const CustomTable({
    Key? key,
    required this.headers,
    required this.rows,
    this.caption,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (caption != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                caption!,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ),
          DataTable(
            headingRowHeight: 40,
            dataRowHeight: 40,
            headingRowColor: MaterialStateProperty.all(Colors.grey[200]),
            columns: headers
                .map(
                  (header) => DataColumn(
                    label: Text(
                      header,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                )
                .toList(),
            rows: rows
                .map(
                  (row) => DataRow(
                    cells: row
                        .map(
                          (cell) => DataCell(
                            Text(
                              cell,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}
