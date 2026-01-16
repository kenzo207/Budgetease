import 'package:flutter/material.dart';
import '../utils/colors.dart';
import '../utils/icons.dart';

class IconPickerDialog extends StatefulWidget {
  final String? selectedIcon;

  const IconPickerDialog({super.key, this.selectedIcon});

  @override
  State<IconPickerDialog> createState() => _IconPickerDialogState();
}

class _IconPickerDialogState extends State<IconPickerDialog> {
  String? _selectedIcon;
  String _selectedGroup = 'Tous';

  @override
  void initState() {
    super.initState();
    _selectedIcon = widget.selectedIcon;
  }

  List<String> _getFilteredIcons() {
    if (_selectedGroup == 'Tous') {
      return getAllIcons();
    }
    final group = iconLibrary.firstWhere(
      (g) => g['group'] == _selectedGroup,
      orElse: () => {'icons': <String>[]},
    );
    return group['icons'] as List<String>;
  }

  @override
  Widget build(BuildContext context) {
    final filteredIcons = _getFilteredIcons();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(16),
        constraints: const BoxConstraints(maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Choisir une icône',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Group filter
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildGroupChip('Tous'),
                  ...iconLibrary.map((group) => _buildGroupChip(group['group'] as String)),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Icon grid
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 6,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: filteredIcons.length,
                itemBuilder: (context, index) {
                  final icon = filteredIcons[index];
                  final isSelected = icon == _selectedIcon;

                  return InkWell(
                    onTap: () => setState(() => _selectedIcon = icon),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: isSelected ? AppColors.primary : AppColors.gray200,
                          width: isSelected ? 2 : 1,
                        ),
                        borderRadius: BorderRadius.circular(8),
                        color: isSelected ? AppColors.primaryLight : Colors.white,
                      ),
                      child: Center(
                        child: Text(
                          icon,
                          style: const TextStyle(fontSize: 28),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),

            // Confirm button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _selectedIcon == null
                    ? null
                    : () => Navigator.pop(context, _selectedIcon),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Confirmer'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupChip(String group) {
    final isSelected = group == _selectedGroup;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(group),
        selected: isSelected,
        onSelected: (selected) => setState(() => _selectedGroup = group),
        selectedColor: AppColors.primaryLight,
        checkmarkColor: AppColors.primary,
      ),
    );
  }
}
