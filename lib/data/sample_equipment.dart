import '../models/equipment.dart';

const List<Equipment> sampleEquipment = [
  Equipment(
    id: 'EQ001',
    name: 'DSLR Camera',
    category: 'Cameras',
    description: 'DSLR camera for photography and university events.',
    condition: 'Good',
    serviceable: true,
  ),
  Equipment(
    id: 'EQ002',
    name: 'Multimedia Projector',
    category: 'Presentation',
    description: 'Multimedia projector for lectures and presentations.',
    condition: 'Good',
    serviceable: true,
  ),
  Equipment(
    id: 'EQ003',
    name: 'Camera Tripod',
    category: 'Accessories',
    description: 'Camera tripod for stable photography and video recording.',
    condition: 'Good',
    serviceable: true,
  ),
  Equipment(
    id: 'EQ004',
    name: 'Wireless Microphone',
    category: 'Audio',
    description: 'Wireless microphone for presentations and university events.',
    condition: 'Requires repair',
    serviceable: false,
  ),
];
