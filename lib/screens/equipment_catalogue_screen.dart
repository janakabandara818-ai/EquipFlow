import 'package:flutter/material.dart';

import '../data/sample_equipment.dart';
import '../models/equipment.dart';

class EquipmentCatalogueScreen extends StatefulWidget {
  const EquipmentCatalogueScreen({super.key});

  @override
  State<EquipmentCatalogueScreen> createState() =>
      _EquipmentCatalogueScreenState();
}

class _EquipmentCatalogueScreenState extends State<EquipmentCatalogueScreen> {
  final TextEditingController _searchController = TextEditingController();

  String _query = '';
  String? _selectedCategory;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _query = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final categories =
        sampleEquipment.map((equipment) => equipment.category).toSet().toList()
          ..sort();

    final categoryOptions = <String?>[null, ...categories];

    final filteredEquipment = sampleEquipment.where((equipment) {
      final searchableText =
          '${equipment.equipmentId} ${equipment.name} ${equipment.category}'
              .toLowerCase();

      final matchesSearch = searchableText.contains(_query);
      final matchesCategory =
          _selectedCategory == null || equipment.category == _selectedCategory;

      return matchesSearch && matchesCategory;
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Equipment Catalogue')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search equipment',
                hintText: 'Name, ID or category',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Clear search',
                        onPressed: _clearSearch,
                        icon: const Icon(Icons.clear),
                      ),
                border: const OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _query = value.trim().toLowerCase();
                });
              },
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: categoryOptions.map((category) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(category ?? 'All'),
                    selected: _selectedCategory == category,
                    onSelected: (selected) {
                      if (!selected) {
                        return;
                      }

                      setState(() {
                        _selectedCategory = category;
                      });
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: filteredEquipment.isEmpty
                ? const Center(child: Text('No equipment found.'))
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    itemCount: filteredEquipment.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final equipment = filteredEquipment[index];

                      return Card(
                        clipBehavior: Clip.antiAlias,
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          leading: Icon(
                            equipment.serviceable
                                ? Icons.inventory_2_outlined
                                : Icons.build_outlined,
                          ),
                          title: Text(equipment.name),
                          subtitle: Text(
                            '${equipment.equipmentId} • '
                            '${equipment.category}\n'
                            '${equipment.serviceable ? 'Serviceable' : 'Under maintenance'}',
                          ),
                          isThreeLine: true,
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            FocusScope.of(context).unfocus();

                            Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (context) => EquipmentDetailsScreen(
                                  equipment: equipment,
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class EquipmentDetailsScreen extends StatelessWidget {
  const EquipmentDetailsScreen({super.key, required this.equipment});

  final Equipment equipment;

  Widget _detail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text('$label: $value', style: const TextStyle(fontSize: 16)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Equipment Details')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Icon(
            equipment.serviceable
                ? Icons.inventory_2_outlined
                : Icons.build_outlined,
            size: 72,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 24),
          Text(
            equipment.name,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 24),
          _detail('Equipment ID', equipment.equipmentId),
          _detail('Category', equipment.category),
          _detail('Condition', equipment.condition),
          _detail(
            'Service status',
            equipment.serviceable ? 'Serviceable' : 'Under maintenance',
          ),
          const SizedBox(height: 12),
          Text('Description', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            equipment.description,
            style: const TextStyle(fontSize: 16, height: 1.5),
          ),
        ],
      ),
    );
  }
}
