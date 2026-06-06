import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/service_provider.dart';
import '../../models/service_details.dart';
import '../../models/service_model.dart';
import '../../constants/colors.dart';

class RolesSkillsScreen extends StatefulWidget {
  final Function(ServiceDetails)? onEdit;
  final VoidCallback? onAdd;

  const RolesSkillsScreen({super.key, this.onEdit, this.onAdd});

  @override
  State<RolesSkillsScreen> createState() => _RolesSkillsScreenState();
}

class _RolesSkillsScreenState extends State<RolesSkillsScreen> {
  ServiceModel? _selectedServiceFilter;
  SubOption? _selectedSubOptionFilter;
  int _currentPage = 0;
  final int _rowsPerPage = 10;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<ServiceProvider>(context, listen: false);
      provider.fetchServiceDetails();
      provider.fetchServices();
    });
  }

  @override
  Widget build(BuildContext context) {
    final serviceProvider = Provider.of<ServiceProvider>(context);
    final flattenedData = _getFlattenedData(serviceProvider.serviceDetails);
    
    // Manual Pagination Logic
    final int totalRecords = flattenedData.length;
    final int totalPages = (totalRecords / _rowsPerPage).ceil();
    final int start = _currentPage * _rowsPerPage;
    final int end = (start + _rowsPerPage < totalRecords) ? start + _rowsPerPage : totalRecords;
    final paginatedData = flattenedData.isNotEmpty ? flattenedData.sublist(start, end) : [];

    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Area
          Wrap(
            spacing: 20,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              const Text('Service Details Management',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              ElevatedButton.icon(
                onPressed: widget.onAdd,
                icon: const Icon(Icons.add),
                label: const Text('Add Detail'),
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15)),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Filter Area
          _buildFilterBar(serviceProvider),
          const SizedBox(height: 24),
          
          // Table Area - Stable DataTable with manual pagination
          Expanded(
            child: serviceProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : flattenedData.isEmpty
                    ? const Center(child: Text('No records found'))
                    : Column(
                        children: [
                          Expanded(
                            child: Card(
                              elevation: 0,
                              clipBehavior: Clip.antiAlias,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(color: Colors.grey.shade200),
                              ),
                              child: SingleChildScrollView(
                                scrollDirection: Axis.vertical,
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: ConstrainedBox(
                                    constraints: const BoxConstraints(minWidth: 1100),
                                    child: DataTable(
                                      headingRowColor: MaterialStateProperty.all(Colors.grey.shade50),
                                      columnSpacing: 30,
                                      columns: const [
                                        DataColumn(label: Text('Service', style: TextStyle(fontWeight: FontWeight.bold))),
                                        DataColumn(label: Text('Category', style: TextStyle(fontWeight: FontWeight.bold))),
                                        DataColumn(label: Text('Sub-Category', style: TextStyle(fontWeight: FontWeight.bold))),
                                        DataColumn(label: Text('Price', style: TextStyle(fontWeight: FontWeight.bold))),
                                        DataColumn(label: Text('Time', style: TextStyle(fontWeight: FontWeight.bold))),
                                        DataColumn(label: Text('Edit', style: TextStyle(fontWeight: FontWeight.bold))),
                                      ],
                                      rows: paginatedData.map((row) {
                                        return DataRow(cells: [
                                          DataCell(SizedBox(width: 200, child: Text(row.detail.name, overflow: TextOverflow.ellipsis))),
                                          DataCell(SizedBox(width: 200, child: Text(row.detail.category, overflow: TextOverflow.ellipsis))),
                                          DataCell(SizedBox(width: 250, child: Text(row.sub?.subCategoryName ?? '-', overflow: TextOverflow.ellipsis))),
                                          DataCell(SizedBox(width: 100, child: Text('₹${row.sub?.price ?? 0}'))),
                                          DataCell(SizedBox(width: 150, child: Text(row.sub?.time ?? '-'))),
                                          DataCell(IconButton(
                                            icon: const Icon(Icons.edit, color: AppColors.accent, size: 20),
                                            onPressed: () => widget.onEdit?.call(row.detail),
                                          )),
                                        ]);
                                      }).toList(),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          // Custom Pagination Footer
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text('Page ${_currentPage + 1} of $totalPages (${totalRecords} items)'),
                                const SizedBox(width: 16),
                                IconButton(
                                  icon: const Icon(Icons.chevron_left),
                                  onPressed: _currentPage > 0 ? () => setState(() => _currentPage--) : null,
                                ),
                                IconButton(
                                  icon: const Icon(Icons.chevron_right),
                                  onPressed: _currentPage < totalPages - 1 ? () => setState(() => _currentPage++) : null,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar(ServiceProvider provider) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Wrap(
        spacing: 16,
        runSpacing: 16,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          const Icon(Icons.filter_list, color: AppColors.accent),
          // Service Dropdown
          SizedBox(
            width: 250,
            child: DropdownButtonFormField<ServiceModel>(
              isExpanded: true,
              value: _selectedServiceFilter,
              decoration: const InputDecoration(
                labelText: 'Filter by Service',
                border: OutlineInputBorder(),
                isDense: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: [
                const DropdownMenuItem<ServiceModel>(
                  value: null,
                  child: Text('All Services'),
                ),
                ...provider.services.map((s) => DropdownMenuItem(
                  value: s,
                  child: Text(s.serviceName, overflow: TextOverflow.ellipsis),
                )),
              ],
              onChanged: (val) {
                setState(() {
                  _selectedServiceFilter = val;
                  _selectedSubOptionFilter = null;
                });
              },
            ),
          ),
          // Sub-Option Dropdown
          SizedBox(
            width: 250,
            child: DropdownButtonFormField<SubOption>(
              isExpanded: true,
              value: _selectedSubOptionFilter,
              decoration: const InputDecoration(
                labelText: 'Filter by Sub-Option',
                border: OutlineInputBorder(),
                isDense: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: [
                const DropdownMenuItem<SubOption>(
                  value: null,
                  child: Text('All Sub-Options'),
                ),
                if (_selectedServiceFilter != null)
                  ..._selectedServiceFilter!.subOptions.map((so) => DropdownMenuItem(
                    value: so,
                    child: Text(so.subOptionName, overflow: TextOverflow.ellipsis),
                  )),
              ],
              onChanged: (val) {
                setState(() {
                  _selectedSubOptionFilter = val;
                });
              },
            ),
          ),
          // Apply Button
          ElevatedButton(
            onPressed: () {
              provider.fetchServiceDetails(
                serviceId: _selectedServiceFilter?.serviceId,
                subOptionId: _selectedSubOptionFilter?.subOptionId,
              );
              setState(() => _currentPage = 0); // Reset page on filter
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            ),
            child: const Text('Apply'),
          ),
          // Clear Button
          TextButton(
            onPressed: () {
              setState(() {
                _selectedServiceFilter = null;
                _selectedSubOptionFilter = null;
                _currentPage = 0;
              });
              provider.fetchServiceDetails();
            },
            child: const Text('Clear Filters'),
          ),
        ],
      ),
    );
  }

  List<_FlattenedDetailRow> _getFlattenedData(List<ServiceDetails> details) {
    List<_FlattenedDetailRow> rows = [];
    for (var detail in details) {
      if (detail.subCategories.isEmpty) {
        rows.add(_FlattenedDetailRow(detail: detail, sub: null));
      } else {
        for (var sub in detail.subCategories) {
          rows.add(_FlattenedDetailRow(detail: detail, sub: sub));
        }
      }
    }
    return rows;
  }
}

class _FlattenedDetailRow {
  final ServiceDetails detail;
  final DetailedSubCategory? sub;

  _FlattenedDetailRow({required this.detail, this.sub});
}
