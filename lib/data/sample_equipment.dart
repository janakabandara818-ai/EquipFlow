import '../models/equipment.dart';

const List<Equipment> sampleEquipment = [
  Equipment(
    equipmentId: 'EQ001',
    name: 'DSLR Camera',
    category: 'Cameras',
    description: 'Camera for photography and event coverage.',
    condition: 'Good',
    serviceable: true,
  ),
  Equipment(
    equipmentId: 'EQ002',
    name: 'Multimedia Projector',
    category: 'Presentation',
    description: 'Projector for presentations and demonstrations.',
    condition: 'Good',
    serviceable: true,
  ),
  Equipment(
    equipmentId: 'EQ003',
    name: 'Camera Tripod',
    category: 'Accessories',
    description: 'Adjustable tripod for stable photography and video.',
    condition: 'Good',
    serviceable: true,
  ),
  Equipment(
    equipmentId: 'EQ004',
    name: 'Wireless Microphone',
    category: 'Audio',
    description: 'Wireless microphone for presentations and events.',
    condition: 'Requires repair',
    serviceable: false,
  ),
];
