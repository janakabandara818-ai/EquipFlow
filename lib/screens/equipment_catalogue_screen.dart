import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import '../data/equipment_repository.dart';
import '../models/equipment.dart';

class EquipmentCatalogueScreen extends StatefulWidget {
  const EquipmentCatalogueScreen({super.key});

  @override
  State<EquipmentCatalogueScreen> createState() =>
      _EquipmentCatalogueScreenState();
}

class _EquipmentCatalogueScreenState extends State<EquipmentCatalogueScreen> {
  final EquipmentRepository _repository = EquipmentRepository();
  final TextEditingController _searchController = TextEditingController();

  late Stream<List<Equipment>> _equipmentStream;

  String _searchQuery = '';
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _equipmentStream = _repository.watchEquipment();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _retry() {
    setState(() {
      _equipmentStream = _repository.watchEquipment();
    });
  }

  void _clearFilters() {
    _searchController.clear();

    setState(() {
      _searchQuery = '';
      _selectedCategory = null;
    });
  }

  String _errorMessage(Object? error) {
    if (error is FirebaseException) {
      switch (error.code) {
        case 'permission-denied':
        case 'unauthenticated':
          return 'Unable to access equipment. '
              'Please log out and log in again. '
              'If the problem continues, contact the administrator.';
        case 'unavailable':
        case 'deadline-exceeded':
          return 'Unable to connect. '
              'Check your internet connection and try again.';
      }
    }

    return 'Unable to load equipment. Please try again.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Equipment Catalogue')),
      body: StreamBuilder<List<Equipment>>(
        stream: _equipmentStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, size: 56),
                    const SizedBox(height: 16),
                    Text(
                      _errorMessage(snapshot.error),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    FilledButton(
                      onPressed: _retry,
                      child: const Text('Try Again'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final equipment = snapshot.data!;

          if (equipment.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'No equipment has been added yet.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final categories =
              equipment.map((item) => item.category).toSet().toList()..sort();

          final activeCategory = categories.contains(_selectedCategory)
              ? _selectedCategory
              : null;

          final filteredEquipment = equipment.where((item) {
            final matchesSearch =
                item.name.toLowerCase().contains(_searchQuery) ||
                item.id.toLowerCase().contains(_searchQuery) ||
                item.category.toLowerCase().contains(_searchQuery);

            final matchesCategory =
                activeCategory == null || item.category == activeCategory;

            return matchesSearch && matchesCategory;
          }).toList();

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search name, ID or category',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isEmpty
                        ? null
                        : IconButton(
                            tooltip: 'Clear search',
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                            icon: const Icon(Icons.clear),
                          ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value.trim().toLowerCase();
                    });
                  },
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    ChoiceChip(
                      label: const Text('All'),
                      selected: activeCategory == null,
                      onSelected: (_) {
                        setState(() {
                          _selectedCategory = null;
                        });
                      },
                    ),
                    for (final category in categories)
                      Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: ChoiceChip(
                          label: Text(category),
                          selected: activeCategory == category,
                          onSelected: (selected) {
                            setState(() {
                              _selectedCategory = selected ? category : null;
                            });
                          },
                        ),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '${filteredEquipment.length} equipment items',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
              ),
              Expanded(
                child: filteredEquipment.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('No matching equipment found.'),
                            const SizedBox(height: 12),
                            TextButton(
                              onPressed: _clearFilters,
                              child: const Text('Clear Filters'),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        itemCount: filteredEquipment.length,
                        itemBuilder: (context, index) {
                          final item = filteredEquipment[index];

                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            clipBehavior: Clip.antiAlias,
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(16),
                              leading: Icon(
                                Icons.inventory_2_outlined,
                                size: 32,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              title: Text(
                                item.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Text(
                                  '${item.id} • ${item.category}\n'
                                  '${item.serviceable ? 'Serviceable' : 'Needs attention'}',
                                ),
                              ),
                              isThreeLine: true,
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute<void>(
                                    builder: (_) =>
                                        EquipmentDetailsScreen(equipment: item),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class EquipmentDetailsScreen extends StatelessWidget {
  const EquipmentDetailsScreen({super.key, required this.equipment});

  final Equipment equipment;

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(title: const Text('Equipment Details')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Icon(Icons.inventory_2_outlined, size: 80, color: primaryColor),
          const SizedBox(height: 24),
          Text(
            equipment.name,
            style: Theme.of(context).textTheme.headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.tag),
                  title: const Text('Equipment ID'),
                  subtitle: Text(equipment.id),
                ),
                ListTile(
                  leading: const Icon(Icons.category_outlined),
                  title: const Text('Category'),
                  subtitle: Text(equipment.category),
                ),
                ListTile(
                  leading: const Icon(Icons.build_outlined),
                  title: const Text('Condition'),
                  subtitle: Text(equipment.condition),
                ),
                ListTile(
                  leading: Icon(
                    equipment.serviceable
                        ? Icons.check_circle_outline
                        : Icons.warning_amber_outlined,
                  ),
                  title: const Text('Serviceability'),
                  subtitle: Text(
                    equipment.serviceable ? 'Serviceable' : 'Needs attention',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text('Description', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(equipment.description, style: const TextStyle(height: 1.5)),
        ],
      ),
    );
  }
}
