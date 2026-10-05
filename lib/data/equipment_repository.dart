import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/equipment.dart';

class EquipmentRepository {
  EquipmentRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Stream<List<Equipment>> watchEquipment() {
    return _firestore.collection('equipment').snapshots().map((snapshot) {
      final equipment = snapshot.docs.map((document) {
        return Equipment.fromMap(id: document.id, data: document.data());
      }).toList();

      equipment.sort((first, second) {
        final nameComparison = first.name.toLowerCase().compareTo(
          second.name.toLowerCase(),
        );

        return nameComparison != 0
            ? nameComparison
            : first.id.compareTo(second.id);
      });

      return equipment;
    });
  }
}
