import 'package:flutter/material.dart';

import '../../domain/entities/public_category.dart';

class PublicCategoryTabs extends StatelessWidget {
  final List<PublicCategory> categories;
  final String? selectedCategoryId;
  final ValueChanged<String?> onChanged;

  const PublicCategoryTabs({
    super.key,
    required this.categories,
    required this.selectedCategoryId,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: const Text('Tudo'),
              selected: selectedCategoryId == null,
              onSelected: (_) => onChanged(null),
            ),
          ),
          ...categories.map(
            (category) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(category.name),
                selected: selectedCategoryId == category.id,
                onSelected: (_) => onChanged(category.id),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
