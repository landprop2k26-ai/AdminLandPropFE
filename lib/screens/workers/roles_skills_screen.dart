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
          
          // Table Area - Expanded to take remaining space and fix crash
          Expanded(
            child: serviceProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : flattenedData.isEmpty
                    ? const Center(child: Text('No records found'))
                    : Card(
                        elevation: 0,
                        clipBehavior: Clip.antiAlias,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Colors.grey.shade200),
                        ),
                        child: Theme(
                          data: Theme.of(context).copyWith(
                            cardTheme: const CardThemeData(elevation: 0, margin: EdgeInsets.zero),
                          ),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(minWidth: 1100),
                              child: SingleChildScrollView(
                                scrollDirection: Axis.vertical,
                                child: PaginatedDataTable(
                                  header: const Text('Inventory'),
                                  rowsPerPage: 10,
                                  columnSpacing: 30,
                                  horizontalMargin: 20,
                                  showFirstLastButtons: true,
                                  columns: const [
                                    DataColumn(label: Text('Service', style: TextStyle(fontWeight: FontWeight.bold))),
                                    DataColumn(label: Text('Category', style: TextStyle(fontWeight: FontWeight.bold))),
                                    DataColumn(label: Text('Sub-Category', style: TextStyle(fontWeight: FontWeight.bold))),
                                    DataColumn(label: Text('Price', style: TextStyle(fontWeight: FontWeight.bold))),
                                    DataColumn(label: Text('Time', style: TextStyle(fontWeight: FontWeight.bold))),
                                    DataColumn(label: Text('Edit', style: TextStyle(fontWeight: FontWeight.bold))),
                                  ],
                                  source: _ServiceDetailsDataSource(
                                    flattenedData,
                                    onEdit: (details) => widget.onEdit?.call(details),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar(ServiceProvider provider) {
    return Container(
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

class _ServiceDetailsDataSource extends DataTableSource {
  final List<_FlattenedDetailRow> data;
  final Function(ServiceDetails) onEdit;

  _ServiceDetailsDataSource(this.data, {required this.onEdit});

  @override
  DataRow? getRow(int index) {
    if (index >= data.length) return null;
    final row = data[index];
    return DataRow(cells: [
      DataCell(SizedBox(width: 200, child: Text(row.detail.name, overflow: TextOverflow.ellipsis))),
      DataCell(SizedBox(width: 200, child: Text(row.detail.category, overflow: TextOverflow.ellipsis))),
      DataCell(SizedBox(width: 250, child: Text(row.sub?.subCategoryName ?? '-', overflow: TextOverflow.ellipsis))),
      DataCell(SizedBox(width: 100, child: Text('₹${row.sub?.price ?? 0}'))),
      DataCell(SizedBox(width: 150, child: Text(row.sub?.time ?? '-'))),
      DataCell(IconButton(
        icon: const Icon(Icons.edit, color: AppColors.accent, size: 20),
        onPressed: () => onEdit(row.detail),
      )),
    ]);
  }

  @override
  bool get isSelected => false;
  @override
  bool get isRowCountApproximate => false;
  @override
  int get rowCount => data.length;
  @override
  int get selectedRowCount => 0;
}
