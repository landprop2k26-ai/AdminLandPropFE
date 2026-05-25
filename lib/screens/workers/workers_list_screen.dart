import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/worker.dart';
import '../../providers/worker_provider.dart';
import '../../constants/colors.dart';

class WorkersListScreen extends StatefulWidget {
  final Function(Worker)? onEdit;
  final VoidCallback? onAdd;

  const WorkersListScreen({super.key, this.onEdit, this.onAdd});

  @override
  State<WorkersListScreen> createState() => _WorkersListScreenState();
}

class _WorkersListScreenState extends State<WorkersListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<WorkerProvider>(context, listen: false).fetchWorkers();
    });
  }

  @override
  Widget build(BuildContext context) {
    final workerProvider = Provider.of<WorkerProvider>(context);

    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('All Workers',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              ElevatedButton.icon(
                onPressed: widget.onAdd,
                icon: const Icon(Icons.add),
                label: const Text('Add Worker'),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Expanded(
            child: workerProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: workerProvider.workers.isEmpty
                        ? const Center(child: Text('No workers found'))
                        : ListView.separated(
                            itemCount: workerProvider.workers.length,
                            separatorBuilder: (context, index) =>
                                const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final worker = workerProvider.workers[index];
                              return ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 12),
                                leading: CircleAvatar(
                                  backgroundColor:
                                      AppColors.accent.withOpacity(0.1),
                                  child: Text(worker.name.isNotEmpty ? worker.name[0] : '?',
                                      style: const TextStyle(
                                          color: AppColors.accent)),
                                ),
                                title: Text(worker.name,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold)),
                                subtitle: Wrap(
                                  spacing: 8,
                                  children: worker.roles
                                      .map((role) => Chip(
                                            label: Text(role,
                                                style: const TextStyle(
                                                    fontSize: 10)),
                                            padding: EdgeInsets.zero,
                                            materialTapTargetSize:
                                                MaterialTapTargetSize
                                                    .shrinkWrap,
                                          ))
                                      .toList(),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        const Text('Status',
                                            style: TextStyle(
                                                fontSize: 10,
                                                color: Colors.grey)),
                                        Text(
                                          worker.isActive
                                              ? 'Active'
                                              : 'Inactive',
                                          style: TextStyle(
                                            color: worker.isActive
                                                ? Colors.green
                                                : Colors.red,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(width: 24),
                                    IconButton(
                                      icon: const Icon(Icons.edit_outlined,
                                          color: AppColors.accent),
                                      onPressed: () {
                                        if (widget.onEdit != null) {
                                          widget.onEdit!(worker);
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
          ),
        ],
      ),
    );
  }
}
